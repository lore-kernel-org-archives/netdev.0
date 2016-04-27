From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 01/20] net: dsa: introduce a dsa_port structure
Date: Thu, 28 Apr 2016 01:07:29 +0200
Message-ID: <20160427230729.GH29024@lunn.ch>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1461796217-18893-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1461796217-18893-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -230,6 +231,13 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
>  	for (i = 0; i < DSA_MAX_PORTS; i++) {
>  		char *name;
>  
> +		dp[i] = devm_kzalloc(parent, sizeof(*dp), GFP_KERNEL);
> +		if (dp[i] == NULL)
> +			return -ENOMEM;

You are not saving anything here by dynamically allocating the memory,
since you do it for all ports. So just make it a member of ds with
size DSA_MAX_PORTS. I would then call this array structure ports.

Humm, i also think keeping it in dsa_slave_priv is wrong, if you have
defined the structure in the global include/net/dsa.h. dsa_switch is a
better place for it.

     Andrew
