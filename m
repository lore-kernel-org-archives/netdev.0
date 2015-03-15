From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 0/3] switchdev: support stp updates on
 stacked netdevices
Date: Sun, 15 Mar 2015 17:56:32 +0100
Message-ID: <20150315165632.GF2043@nanopsycho.orion>
References: <1426206598-29410-1-git-send-email-roopa@cumulusnetworks.com>
 <20150313.001007.65274068513753002.davem@davemloft.net>
 <5502E544.7030003@cumulusnetworks.com>
 <20150313.123156.2118585119289960334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, sfeldma@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:36147 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbbCOQ4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 12:56:37 -0400
Received: by wibg7 with SMTP id g7so21113898wib.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 09:56:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150313.123156.2118585119289960334.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 13, 2015 at 05:31:56PM CET, davem@davemloft.net wrote:
>From: roopa <roopa@cumulusnetworks.com>
>Date: Fri, 13 Mar 2015 06:25:24 -0700
>
>> David, if you mean not touch bond and team but have the switchdev
>> api do it transparently, yes, i had it that way initially.  And i do
>> liked it that way as well. But the feedback i received (during the
>> initial introduction of this for setlink/dellink) was to make it
>> explicit for each master.
>
>I think the concern is that we only want to do this for devices
>for which it is safe to "traverse" down like this.

Yes, that was my point. Also, some layered drivers might want to do some
individual magic, propagate on condition, etc. I think it is clearer
architecture. And also, you can see right away what is happening. By
doing the travelsal directly in switchdev code, that is in the shadow :/


>
>But frankly I cannot think of any layered device where we would
>not want to do this.
>
>Let's go back to the simple scheme where we unconditionally traverse
>and if we hit a problem case we'll figure out how to deal with it
>then, ok?
