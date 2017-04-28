From: Alexei Starovoitov <ast@fb.com>
Subject: Re: xdp_redirect ifindex vs port. Was: best API for returning/setting
 egress port?
Date: Thu, 27 Apr 2017 22:30:46 -0700
Message-ID: <b15f490d-5490-e309-9626-d35b8e932483@fb.com>
References: <58F7E9F3.5090604@iogearbox.net>
 <20170420025611.GA53935@ast-mbp.thefacebook.com>
 <20170420081051.77a41aa8@redhat.com>
 <20170420171006.GA97067@ast-mbp.thefacebook.com>
 <20170425113453.5c72080f@redhat.com>
 <20170426002610.eihwmz4knbmrolfw@ast-mbp.dhcp.thefacebook.com>
 <59000EF6.1050204@gmail.com> <20170426111158.578b925e@redhat.com>
 <5900CC41.2070502@gmail.com> <c9b3ff9b-8938-3274-da29-c04f9da2a314@fb.com>
 <20170426205544.GA40859@C02RW35GFVH8> <20170427104121.32df2178@redhat.com>
 <53e9dd2f-f40a-b43b-99c9-62f5ce3a665c@fb.com> <5902CDC5.5010209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36702 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1423900AbdD1FbO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 01:31:14 -0400
In-Reply-To: <5902CDC5.5010209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/27/17 10:06 PM, John Fastabend wrote:
> That is more or less what I was thinking as well. The other question
> I have though is should we have a bpf_redirect() call for the simple
> case where I use the ifindex directly. This will be helpful for taking
> existing programs from tc_cls into xdp. I think it makes sense to have
> both bpf_tx_allports(), bpf_tx_port(), and bpf_redirect().

I think so too.
Once netdevice is stored into netdev_array map the netdevice is pinned
and we need to figure out what to do if somebody tries to delete it.
Should we add a new netlink notifier that this netdev's refcnt is
almost zero and it's only in netdev_array(s) ?
or should it be deleted from the array(s) automatically and
then user space will be notified post-deletion?
Both approaches have their pros and cons.

Whereas raw ifindex approach (via bpf_redirect) doesn't have these
caveats. It's clear to both bpf prog and user space that ifindex
can be stale and user space needs to monitor netdevs and update
programs/maps.
