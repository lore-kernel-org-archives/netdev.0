From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: tcp: Fix a PTO timing granularity issue
Date: Tue, 26 May 2015 11:13:12 -0700
Message-ID: <1432663992.4060.286.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432650358-11470-1-git-send-email-ido@wizery.com>
	 <1432657435.4060.267.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150526170222.GA13376@WorkStation.home>
	 <1432660420.4060.271.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150526175540.GB13376@WorkStation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Nandita Dukkipati <nanditad@google.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ido Yariv <idox.yariv@intel.com>
To: Ido Yariv <ido@wizery.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150526175540.GB13376@WorkStation.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-26 at 13:55 -0400, Ido Yariv wrote:
> Hi Eric,
> 

> 
> I understand, and I also suspect that having it expire after 9ms will
> have very little impact, if at all.
> 
> Since it mainly affects HZ=100 systems, we can simply go with having at
> least 2 jiffies on these systems, and leave everything else as is.
> 
> However, if the 10ms has a special meaning (couldn't find reasoning for
> it in the RFC), making sure this timer doesn't expire prematurely could
> be beneficial. I'm afraid this was not tested on the setup mentioned
> above though.
> 


RFC did not explain how 10ms delay was implemented. This is the kind of
dark side. RFC are full of 'unsaid things', like OS bugs.

What is not said in TLP paper is : linux timers have a 'jiffie'
granularity that might be 1/100, 1/250, 1/1000, or even 1/64 on Alpha
processors...

Fact is : We did TLP implementation and experimentations and paper at
the same time, and we do not want to change the current behavior on
HZ=1000 hosts. This is the kind of change that would require lot of
tests for Google. 

Please resend your patch so that only HZ <= 100 is changed, we will
happily acknowledge it.

Thanks
