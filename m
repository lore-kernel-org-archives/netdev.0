From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: commit f5f99309 (sock: do not set sk_err in
 sock_dequeue_err_skb) has broken ping
Date: Thu, 1 Jun 2017 22:03:14 +0200
Message-ID: <20170601200314.GD10526@rei.suse.de>
References: <20170601140048.GA24401@rei.lan>
 <CACSApvZiQTYSVkS62YdadjabUTqwO9O2=Sq4ELuO3eoJ_LM_ZQ@mail.gmail.com>
 <20170601143141.GB24401@rei.lan>
 <CACSApvbKwbX2u16V1oQfmHC7SvGZgk-KehA9tashjQAtj0bB0Q@mail.gmail.com>
 <20170601151003.GB10526@rei.suse.de>
 <CACSApvanT0ZRFH0ZBDLqygkH6Ue_CCVQBzVL9fCmZE_BndYEog@mail.gmail.com>
 <20170601153645.GC10526@rei.suse.de>
 <CACSApvb_CtFEenaSGcpUk6yb8O3X95MAULkJ-+T1hscCE_O_jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Pravin B Shelar <pshelar@ovn.org>,
        Eric Dumazet <edumazet@google.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Yaogong Wang <wygivan@google.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Soheil Hassas Yeganeh <soheil@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACSApvb_CtFEenaSGcpUk6yb8O3X95MAULkJ-+T1hscCE_O_jg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!
> Thank you very much! I have a wild guess that, when we
> have a train of skbs on the error queue starting from a local error,
> we will see this issue.
> 
> Ping (without my patch) considers EAGAIN on a normal read as an
> indication that there is nothing on the error queue, but that's a
> flawed assumption.
> 
> Would you mind trying another shot in the darkness please? Thanks!

This patch seems to fix the issue, I've tried several times and poll()
just timeouts, haven't seen a single POLLERR in the ping strace.

You can add my Tested-by: for this patch as well :-).

-- 
Cyril Hrubis
chrubis@suse.cz
