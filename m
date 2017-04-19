From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: XDP question: best API for returning/setting egress port?
Date: Thu, 20 Apr 2017 00:51:31 +0200
Message-ID: <58F7E9F3.5090604@iogearbox.net>
References: <20170418215856.5fda7127@redhat.com> <20170419200259.GK4730@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>
To: Andy Gospodarek <andy@greyhouse.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47034 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764773AbdDSWvh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 18:51:37 -0400
In-Reply-To: <20170419200259.GK4730@C02RW35GFVH8.dhcp.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2017 10:02 PM, Andy Gospodarek wrote:
[...]
> and then lookup this dest in a table we have the option to make that
> dest an ifindex/socket/other.
>
> I did also look at JohnF's patch and I do like the simplicity of the redirect
> action and new ndo_xdp_xmit and how it moves towards a way to transmit the
> frame.  The downside is that it presumes an ifindex, so it might not be ideal
> we want the lookup to return something other than an ifindex.
>
[...]
> would be handled.  If we are ultimately going to need a new netdev op to
> handle the redirect then what may be the issue with not providing the
> destination port the return code and the option proposed by JohnF looks
> good to me with maybe a small tweak to not presume ifindex in some manner.

Is there a concrete reason that all the proposed future cases like sockets
have to be handled within the very same XDP_REDIRECT return code? F.e. why
not XDP_TX_NIC that only assumes ifindex as proposed in the patch, and future
ones would get a different return code f.e. XDP_TX_SK only handling sockets
when we get there implementation-wise?
