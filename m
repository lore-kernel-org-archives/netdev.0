From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ss: 64bit inode numbers
Date: Wed, 13 Apr 2016 14:21:21 -0700
Message-ID: <1460582481.10638.39.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460499749.6473.601.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160413135511.4e683440@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35318 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbcDMVVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 17:21:24 -0400
Received: by mail-pa0-f46.google.com with SMTP id fs9so19163035pac.2
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 14:21:23 -0700 (PDT)
In-Reply-To: <20160413135511.4e683440@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-13 at 13:55 -0700, Stephen Hemminger wrote:
> On Tue, 12 Apr 2016 15:22:29 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Lets prepare for a possibility to have 64bit inode numbers for sockets,
> > even if the kernel currently enforces 32bit numbers.
> > 
> > Presumably, if both kernel and userland are 64bit (no 32bit emulation),
> > kernel could switch to 64bit inode numbers soon.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>  
> Why not use ino_t rather than __u64 which is really intended for kernel/user abi.
> Then make code generic on sizeof inode type

Well, maybe because code dealing with ino_t is very often buggy ;)

For example iproute2 makes the assumption an ino_t can be printed using
%lu format. This does not work with a 32bit binary.


static void bpf_info_loop(int *fds, struct bpf_map_aux *aux)
{
        int i, tfd[BPF_MAP_ID_MAX];

        printf("ver: %d\nobj: %s\ndev: %lu\nino: %lu\nmaps: %u\n",
               aux->uds_ver, aux->obj_name, aux->obj_st.st_dev,
               aux->obj_st.st_ino, aux->num_ent);

...

No strong preference from my side.
