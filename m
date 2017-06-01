From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: commit f5f99309 (sock: do not set sk_err in
 sock_dequeue_err_skb) has broken ping
Date: Thu, 1 Jun 2017 17:36:45 +0200
Message-ID: <20170601153645.GC10526@rei.suse.de>
References: <20170601140048.GA24401@rei.lan>
 <CACSApvZiQTYSVkS62YdadjabUTqwO9O2=Sq4ELuO3eoJ_LM_ZQ@mail.gmail.com>
 <20170601143141.GB24401@rei.lan>
 <CACSApvbKwbX2u16V1oQfmHC7SvGZgk-KehA9tashjQAtj0bB0Q@mail.gmail.com>
 <20170601151003.GB10526@rei.suse.de>
 <CACSApvanT0ZRFH0ZBDLqygkH6Ue_CCVQBzVL9fCmZE_BndYEog@mail.gmail.com>
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
In-Reply-To: <CACSApvanT0ZRFH0ZBDLqygkH6Ue_CCVQBzVL9fCmZE_BndYEog@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!
> >> Thank you for the confirmation. Could you please try the following
> >> patch to see if it fixes your issue?
> >
> > Does not seem to help, I still got the same bussy loop.
> 
> Thank you for trying the patch. Unfortunately, I can't reproduce on my
> machines here.Would you humor me with another one? Thank you!

Still does not help.

I've modified the ping binary (on the top of you patch that reads the
error queue) to dump the error structure.

It seems to repeatedly produce (until I plug the cable back):

ee_errno = 113 ee_origin = 2 ee_type = 3 ee_code = 1 ee_info = 0 ee_data = 0

So we get EHOSTUNREACH on SO_EE_ORIGIN_ICMP.

-- 
Cyril Hrubis
chrubis@suse.cz
