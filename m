From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RESEND net] nfc: use GFP_USER for user-controlled kmalloc
Date: Tue, 26 Jan 2016 18:23:08 -0800
Message-ID: <1453861388.11327.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453830820-27104-1-git-send-email-xiyou.wangcong@gmail.com>
	 <CAGRGNgV7MUXdk+e8Arx05yiWX6owei5dmnFQ-TBfs55jfy+qBw@mail.gmail.com>
	 <CAM_iQpWawou1Z_NnAzM5TxH7TUQUCAhf+k96PErNV8q_SOCShw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Calaby <julian.calaby@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:32835 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946AbcA0CXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 21:23:11 -0500
In-Reply-To: <CAM_iQpWawou1Z_NnAzM5TxH7TUQUCAhf+k96PErNV8q_SOCShw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-26 at 15:12 -0800, Cong Wang wrote:
> On Tue, Jan 26, 2016 at 2:55 PM, Julian Calaby <julian.calaby@gmail.com> wrote:
> > Hi Cong,
> >
> > On Wed, Jan 27, 2016 at 4:53 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> >
> > A commit message would be nice. A brief rundown of how this is called
> > from userspace would be nice (I'm talking a single sentence here, e.g.
> > "this is allocated when submitting a nfc packet") and what issue
> > __GFP_NOWARN is fixing. (I'm guessing log spam due to allocation
> > failures.)
> >
> 
> I thought it is obvious. ;) Keep in mind that $subject is one part of commit
> message too, so there is a commit message although very short.
> 
> I will add it.


BTW, kzalloc() is useless here, since it is followed by

if (memcpy_from_msg(msg_data, msg, len)) {

Also, this file seems to have two spots with the same problem,
in nfc_llcp_send_ui_frame() & nfc_llcp_send_i_frame()
