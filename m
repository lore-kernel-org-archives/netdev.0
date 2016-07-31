From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH] net: thunderx: correct bound check in nic_config_loopback
Date: Mon, 1 Aug 2016 00:41:52 +0800
Message-ID: <CA+sq2Cc-MTtoncAcL6MS-YVdeVVK=aqEmZakzkX6_CwsXvpRCQ@mail.gmail.com>
References: <1469933384-16827-1-git-send-email-alexander.levin@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "sgoutham@cavium.com" <sgoutham@cavium.com>,
	"rric@kernel.org" <rric@kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Levin, Alexander" <alexander.levin@verizon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469933384-16827-1-git-send-email-alexander.levin@verizon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for finding.
A much better fix would be,

-       if (lbk->vf_id > MAX_LMAC)
+       if (lbk->vf_id >= nic->num_vf_en)
                return -1;

where 'num_vf_en' reflects the exact number of physical interfaces or
LMACs on the system.

Thanks,
Sunil.
