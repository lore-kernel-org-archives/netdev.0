From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Sun, 16 Apr 2017 22:26:01 +0200
Message-ID: <20170416222601.671f037c@redhat.com>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
        <20170413042036.GA46229@ast-mbp.thefacebook.com>
        <20170413.113722.2174945057832588335.davem@davemloft.net>
        <20170414110525.41317f5a@redhat.com>
        <20170414192814.GD41922@ast-mbp.thefacebook.com>
        <20170414153032.2b3e1a5c@cakuba.lan>
        <20170415004642.GA73685@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <kubakici@wp.pl>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36262 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756758AbdDPU0I (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Apr 2017 16:26:08 -0400
In-Reply-To: <20170415004642.GA73685@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Apr 2017 17:46:44 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> But that's probably bad idea, since I was assuming that such ring
> reconfiguration can be made fast, which is unlikely.
> If it takes seconds to setup a ring, then drivers should just
> assume XDP_PACKET_HEADROOM, since at that time the program
> properties are unknown and in the future other programs will be loaded.
>
> Take a look at our current setup with slots for xdp_dump, ddos, lb
> programs. Only root program is attached at the begining.
> If the driver configures the ring for such empty program that would break
> dynamic addition of lb prog.
> The driver must not interrupt the traffic when user adds another
> prog to prog array. In such case XDP side doesn't even know that
> prog array is used. It's all happening purely on bpf side.

The bpf tail-call use-case is a very good example of why the verifier
cannot deduct the needed HEADROOM upfront.

Could we still make the verifier reject a program getting attached as a
tail-call when a too "low"/small HEADROOM have been setup? (to satisfy
programs needs)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
