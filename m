From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/1] wireless: move ifs' in _rtl92c_store_pwrIndex_diffrate_offset into elseif statements
Date: Mon, 6 Feb 2012 11:26:37 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E58@saturn3.aculab.com>
References: <4F2EA8D8.4080907@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Devendra.Naga" <devendra.aaru@gmail.com>,
	<chaoming_li@realsil.com.cn>, <linville@tuxdriver.com>,
	<paul.gortmaker@windriver.com>, <joe@perches.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Larry Finger" <Larry.Finger@lwfinger.net>,
	"Jan Ceuleers" <jan.ceuleers@computer.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4F2EA8D8.4080907@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Yes, it is correct. It might be clearer if it were written as 
> a switch statement, but that would be a lot more intrusive.
> Besides, have you ever looked at the way gcc compiles a switch?

How gcc compiles a switch statement depends (amongst other
things) on whether the labels form a 'dense set' or not.
If they are dense it will usually generate a jump table.
If they are not dense it will compare against the 'middle'
entry first and generate a tree of conditionals.
An 'else if' chain is a linear search.

If the performance of the code matters in can be worth
an explicit test for the common case outside the switch.
Alternatively an 'if else' chain with every conditional
marked 'unlikely' should generate exactly one mispredicted
branch (if you can force static branch prediction).

There are further constraints that apply to some cpus.

Mostly it isn't worth worrying about - although a lot of
code can be significantly sped up by avoiding/containing
register spills and mis-predicted branches.

The code is question seemed to be checking bits, not
an ordinal - so changing to a case might be problematic.
(Could more than one bit bet set????)

	David
