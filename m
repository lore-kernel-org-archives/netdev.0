From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v2 2/3] r8152: clear theflagofSCHEDULE_TASKLETin
 tasklet
Date: Sat, 8 Nov 2014 23:11:49 +0100
Message-ID: <20141108221149.GA26030@electric-eye.fr.zoreil.com>
References: <1394712342-15778-75-Taiwan-albertk@realtek.com>
 <1394712342-15778-79-Taiwan-albertk@realtek.com>
 <1394712342-15778-81-Taiwan-albertk@realtek.com>
 <20141031.161520.3547230591227504.davem@davemloft.net>
 <0835B3720019904CB8F7AA43166CEEB2ECD8A7@RTITMBSV03.realtek.com.tw>
 <20141102225307.GA19900@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB2ECDFC2@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2ECDFC2@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
>  Francois Romieu [mailto:romieu@fr.zoreil.com] 
> > Sent: Monday, November 03, 2014 6:53 AM
> [...]
> > test_and_clear_bit (dense) or clear_bit would be more idiomatic.
> 
> Excuse me. Any suggestion?
> Should I use clear_bit directly, or something else?
> Or, do I have to remove this patch?

The performance explanation leaves me a bit unconvinced. Without any
figure one could simply go for the always locked clear_bit because of:
1. the "I'm racy" message that the open-coded test + set sends
2. the extra work needed to avoid 1 (comment, explain, ...).

The extra time could thus be used to see what happens when napi is
shoehorned in this tasklet machinery. I'd naively expect it to be
relevant for efficiency.

I won't mind if your agenda is completely different. :o)

-- 
Ueimor
