From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] ip route: Make name of protocol 0
 consistent
Date: Sat, 18 Feb 2017 16:09:04 -0800
Message-ID: <20170218160904.552af369@xeon-e3>
References: <1487017313-8000-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36273 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdBSAJc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 19:09:32 -0500
Received: by mail-pf0-f182.google.com with SMTP id 189so21553677pfu.3
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 16:09:14 -0800 (PST)
In-Reply-To: <1487017313-8000-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Feb 2017 12:21:53 -0800
David Ahern <dsa@cumulusnetworks.com> wrote:

> iproute2 can inconsistently show the name of protocol 0 if a route with
> a custom protocol is added. For example:
>   dsa@cartman:~$ ip -6 ro ls table all | egrep 'proto none|proto unspec'
>   local ::1 dev lo  table local  proto none  metric 0  pref medium
>   local fe80::225:90ff:fecb:1c18 dev lo  table local  proto none  metric 0  pref medium
>   local fe80::92e2:baff:fe5c:da5d dev lo  table local  proto none  metric 0  pref medium
> 
> protocol 0 is pretty printed as "none". Add a route with a custom protocol:
>   dsa@cartman:~$ sudo ip -6 ro add  2001:db8:200::1/128 dev eth0 proto 123
> 
> And now display has switched from "none" to "unspec":
>   dsa@cartman:~$ ip -6 ro ls table all | egrep 'proto none|proto unspec'
>   local ::1 dev lo  table local  proto unspec  metric 0  pref medium
>   local fe80::225:90ff:fecb:1c18 dev lo  table local  proto unspec  metric 0  pref medium
>   local fe80::92e2:baff:fe5c:da5d dev lo  table local  proto unspec  metric 0  pref medium
> 
> The rt_protos file has the id to name mapping as "unspec" while
> rtnl_rtprot_tab[0] has "none". The presence of a custom protocol id
> triggers reading the rt_protos file and overwriting the string in
> rtnl_rtprot_tab. All of this is logic from 2004 and earlier.
> 
> Update rtnl_rtprot_tab to "unspec" to match the enum value.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks.
