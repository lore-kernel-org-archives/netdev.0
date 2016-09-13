From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH v3 2/3] e1000: add initial XDP
 support
Date: Tue, 13 Sep 2016 16:40:41 -0700
Message-ID: <20160913234039.GA42336@ast-mbp.thefacebook.com>
References: <20160913012815.GB25756@ast-mbp.thefacebook.com>
 <CALx6S36u+tQUEVhu0BaLZ6-_0=GSMwxd4m89-H+brVZ-rr-U2g@mail.gmail.com>
 <20160913171340.GA37341@ast-mbp.thefacebook.com>
 <1473788252.18970.177.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160913175926.GA38737@ast-mbp.thefacebook.com>
 <36ECC79A-0810-4D06-A72D-702AD9901E83@intel.com>
 <20160913182959.GA38950@ast-mbp.thefacebook.com>
 <AB6E7248-F1A3-4C9C-9249-7F25E51BA1E4@intel.com>
 <20160913215208.GA40872@ast-mbp.thefacebook.com>
 <151DF165-61A2-428A-BD24-04E7704F9724@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        William Tu <u9012063@gmail.com>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:32861 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753442AbcIMXkr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 19:40:47 -0400
Received: by mail-pa0-f66.google.com with SMTP id h5so201729pao.0
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 16:40:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <151DF165-61A2-428A-BD24-04E7704F9724@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 13, 2016 at 10:41:12PM +0000, Rustad, Mark D wrote:
> That said, I can see that you have tried to keep the original code path
> pretty much intact. I would note that you introduced rcu calls into the !bpf
> path that would never have been done before. While that should be ok, I
> would really like to see it tested, at least for the !bpf case, on real
> hardware to be sure. 

please go ahead and test. rcu_read_lock is zero extra instructions
for everything but preempt or debug kernels.
