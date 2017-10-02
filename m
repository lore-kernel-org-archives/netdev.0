From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: tc-ipt v0.2: Extension does not know id 1504083504
Date: Sun, 1 Oct 2017 21:16:35 -0700
Message-ID: <a91341e4-d50e-8745-db59-95da6e84bc33@fatooh.org>
References: <CAGv8E+x_4mkFrKaoJgh8dnh6ZyN7oSHRCpT6GQZKFRECOn8EtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "Sergey K." <simkergey@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from juniper.fatooh.org ([173.255.221.30]:53516 "EHLO
        juniper.fatooh.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751252AbdJBEQg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 00:16:36 -0400
In-Reply-To: <CAGv8E+x_4mkFrKaoJgh8dnh6ZyN7oSHRCpT6GQZKFRECOn8EtQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-10-01 07:25, Sergey K. wrote:
> Hi Corey.
> 
> I did it on your recommendation, replaced xtables.h file from my
> version of iptables 1.6.0, and replaced the file netfilter.h.
> 
> Now it's works, but new construction doesn't:
> 
> # tc filter add dev eth0 parent ffff: u32 match u32 0 0 action xt -j
> SET --map-set WORLD_QoS dst
> xt: unrecognized option '--map-set'
> failed to find target (null)

I looked into this for a bit, and it seems to be due to the SET 
extension not supporting the x6-style options (I don't know the proper 
name for it).

 From the iptables source:

$ grep -c x6 extensions/libxt_MARK.c
9

$ grep -c x6 extensions/libxt_SET.c
0

I got lost in gdb for a while and didn't come up with an easy answer. 
The options in are in the struct, just not where tc is looking.

(gdb) print *m->extra_opts
$3 = {name = 0x7ffff6f1dad8 "add-set", has_arg = 1, flag = 0x0, val = 49}

(gdb) print *(m->extra_opts+4)
$7 = {name = 0x7ffff6f1db03 "map-set", has_arg = 1, flag = 0x0, val = 53}


I don't know if the problem is in iptables or in tc. Somebody familiar 
with the code and its history could probably answer it easily, but I'm 
not at all familiar with it. Sorry. Hopefully somebody else will jump in 
and help you out.

-Corey
