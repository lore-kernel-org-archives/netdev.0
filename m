From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: Deleting a dynamic mac entry..
Date: Tue, 23 May 2017 12:17:39 +0900
Message-ID: <e6143108-3eb4-6f6a-c58b-857722f706b9@lab.ntt.co.jp>
References: <CA+N+6-xY7+coc6zFqzP665WMhbGFFMHOfre9wNxRAcSF2Bthzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Manohar Kumar <forwardinglnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:33475 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932968AbdEWDR6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 23:17:58 -0400
In-Reply-To: <CA+N+6-xY7+coc6zFqzP665WMhbGFFMHOfre9wNxRAcSF2Bthzw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/05/21 11:28, Manohar Kumar wrote:
> Hello,
> 
> In 3.19 the following bridge fdb command to delete a dynamically
> learned entry fails..
> 
> root@net-3:~# bridge fdb show | grep 02:42:0a:ff:00:06
> 02:42:0a:ff:00:06 dev vxlan0 master br0
> root@net-3:~# bridge fdb del 02:42:0a:ff:00:06 dev vxlan0 master
> RTNETLINK answers: No such file or directory
> 
> It works in 4.4.
> 
> Can someone please point to the patch that made this change ?

25d3b493a52d ("bridge: Fix inability to add non-vlan fdb entry") might
be what you are looking for, but you might want to do git-bisect to
track down any regression or fix.

> In kernels without this patch is there an alternative to delete
> (actually I want to do it programmatically) dynamic mac entries ?

If 25d3b493a52d is causing your problem, set default_pvid to 0 in order
to disable default_pvid, and delete any vlans which is already
configured in bridge's vlan_filtering. Then, delete the fdb entry.

Toshiaki Makita
