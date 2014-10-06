From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net-next] r8169:add support for RTL8168EP
Date: Tue, 7 Oct 2014 00:12:50 +0200
Message-ID: <20141006221250.GA10936@electric-eye.fr.zoreil.com>
References: <1412328052-8480-1-git-send-email-hau@realtek.com>
 <20141003203244.GA19965@electric-eye.fr.zoreil.com>
 <80377ECBC5453840BA8C7155328B537765786D@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hau <hau@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <80377ECBC5453840BA8C7155328B537765786D@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hau <hau@realtek.com> :
[...]
> Do you mean I should collect similar hardware parameters setting into one
> function ? or I should set hardware parameters according to hardware
> feature support version?

static void r8168dp_ocp_write(...)
[...]

static void r8168ep_ocp_write(...)
[...]

static void ocp_write(...)
{
	switch (...
	case ...
		r8168dp_ocp_write

	case ...
		r8168ep_ocp_write
[...]

static void rtl8168dp_driver_start(...)
[...]

static void rtl8168ep_driver_start(...)
[...]

etc.

Nothing more. At some point the helpers themselves may turn into data
struct members. Things don't need to be immediately right - if ever.
However you really want to avoid unrelated changes in your patches:
shuffling code and changing features at the same time hurts reviews,
late regression hunts, backports, etc.

-- 
Ueimor
