From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [BUG] af_unix race in close?
Date: Wed, 23 Sep 2009 22:56:11 -0700
Message-ID: <20090923225611.425f40e5@nehalam>
References: <20090923165421.60e0d49c@s6510>
	<4ABAF727.8060905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jike Song <albcamus@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49948 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518AbZIXF4N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2009 01:56:13 -0400
In-Reply-To: <4ABAF727.8060905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Sep 2009 06:35:51 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> inted (2.6.31-0.125.4.2.rc5.git2.fc12.i686 #1) AOA110
> > EIP: 0060:[] EFLAGS: 00010202 CPU: 0
> > EIP is at unix_write_space+0x45/0x87
> > EAX: 6b6b6b6b EBX: ec988780 ECX: 00000000 EDX: 6b6b6b8f
> > ESI: ec988950 EDI: ffffff20 EBP: ec941e28 ESP: ec941e1c
> >  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> > Process metacity (pid: 6809, ti=ec940000 task=e63095c0 task.ti=ec940000)
> > Stack:
> >  37dc7803 ec988780 000000e1 ec941e40 c0772142 37dc7803 dcc1c900 dcc1c900  
> > <0> c07f6a02 ec941e50 c0775766 37dc7803 dcc1c900 ec941e60 c07754ae 37dc7803
> > <0> dcc1c900 ec941e78 c07755db 37dc7803 ec98b0c0 dcc1c900 00000000 ec941ea0  
> > Call Trace:
> >  [] ? sock_wfree+0x44/0x68
> >  [] ? unix_release_sock+0x182/0x1e0
> >  [] ? skb_release_head_state+0x6c/0xcb
> >  [] ? __kfree_skb+0x20/0x94
> >  [] ? kfree_skb+0x68/0x7f
> >  [] ? unix_release_sock+0x182/0x1e0
> >  [] ? unix_release+0x2f/0x42
> >  [] ? sock_release+0x29/0x7f
> >  [] ? sock_close+0x30/0x45
> >  [] ? __fput+0x101/0x1a2

Good thanks. It should probably go up to stable as well.
