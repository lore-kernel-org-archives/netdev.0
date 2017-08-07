From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 05/27] ip: ipaddress.c: add support for json output
Date: Mon, 7 Aug 2017 09:12:58 -0700
Message-ID: <20170807091258.7c70ff87@xeon-e3>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
        <20170803155515.99226-6-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, dsa@cumulusnetworks.com
To: Julien Fortin <julien@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:32902 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751876AbdHGQNA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 12:13:00 -0400
Received: by mail-pg0-f53.google.com with SMTP id u5so3486825pgn.0
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 09:13:00 -0700 (PDT)
In-Reply-To: <20170803155515.99226-6-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  3 Aug 2017 17:54:53 +0200
Julien Fortin <julien@cumulusnetworks.com> wrote:

> From: Julien Fortin <julien@cumulusnetworks.com>
> 
> This patch converts all output (mostly fprintfs) to the new ip_print api
> which handle both regular and json output.
> Initialize a json_writer and open an array object if -json was specified.
> Note that the JSON attribute naming follows the NETLINK_ATTRIBUTE naming.
> 
> In many places throughout the code, IP, matches integer values with
> hardcoded strings tables, such as link mode, link operstate or link
> family.
> In JSON context, this will result in a named string field. In the
> very unlikely event that the requested index is out of bound, IP
> displays the raw integer value. For JSON context this result in
> having a different integer field example bellow:
> 
> if (mode >= ARRAY_SIZE(link_modes))
> 	print_int(PRINT_ANY, "linkmode_index", "mode %d ", mode);
> else
> 	print_string(PRINT_ANY, "linkmode", "mode %s ",
> 		     link_modes[mode]);
> 
> The "_index" suffix is open to discussion and it is something that I came
> up with. The bottom line is that you can't have a string field that may
> become an int field in specific cases. Programs written in strongly type
> languages (like C) might break if they are expecting a string value and
> got an integer instead. We don't want to confuse anybody or make the code
> even more complicated handling these specifics cases.
> Hence the extra "_index" field that is easy to check for and deal with.
> 

This patch does not apply to current master branch.
Please rebase.
