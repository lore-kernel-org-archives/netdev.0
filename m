From: David Ahern <dsahern@gmail.com>
Subject: Re: RFH: problems with adjacency graph
Date: Tue, 11 Oct 2016 13:08:13 -0600
Message-ID: <acf15c25-a5fa-fbf6-c387-7cec302dc052@gmail.com>
References: <7e8a1f21-3227-e27b-7bb7-42fbf49c38ed@gmail.com>
 <20161011065432.GA2018@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: vfalico@gmail.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        roopa <roopa@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33371 "EHLO
        mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751532AbcJKTIv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 15:08:51 -0400
Received: by mail-pa0-f41.google.com with SMTP id vu5so19501598pab.0
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 12:08:16 -0700 (PDT)
In-Reply-To: <20161011065432.GA2018@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/16 12:54 AM, Jiri Pirko wrote:
>>
>> It seems like the complete mesh is not really needed, but cscope shows spectrum, ixgbe and bonding all using the for_each upper and lower device macros.
>>
>> Suggestions?
> 
> Well other possibility is to traverse the tree recursively. But that is
> exactly why the colided lists of all uppers/lowers were introduced to
> avoid this.

The simpler approach is to remove all_adj_list completely and iteratively walk the lower and upper lists in adj_list for the macros that walk all lower and all upper devices. Maintaining a complete linear list per netdev of all lower devices and all upper devices is just not going to work given all combinations of enslave orderings and considering stacks as high as 6 deep. As far as I can tell the netdev_for_each_all_lower_dev, netdev_for_each_all_lower_dev_rcu, and netdev_for_each_all_upper_dev_rcu macros are all used in the slow path so it should be ok. Removing all_adj_list significantly simplifies the dev insert and remove code.
