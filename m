From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qed: fix qed_fill_link() error handling
Date: Tue, 31 May 2016 14:20:46 -0700 (PDT)
Message-ID: <20160531.142046.2026659803711147043.davem@davemloft.net>
References: <1464623197-2084229-1-git-send-email-arnd@arndb.de>
	<CO2PR11MB00881A57063B9AB617359A9097450@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, manish.chopra@qlogic.com,
	Sudarsana.Kalluru@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CO2PR11MB00881A57063B9AB617359A9097450@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 30 May 2016 16:24:07 +0000

>> +	if (IS_ENABLED(CONFIG_QED_SRIOV) && !IS_PF(hwfn->cdev)) {
>> +		qed_vf_get_link_params(hwfn, params);
>> +		qed_vf_get_link_state(hwfn, link);
>> +		qed_vf_get_link_caps(hwfn, link_caps);
>> +
>> +		return 0;
>> +	}
> 
> The IS_ENABLED here seems a bit wasteful to me - we have empty implementation
> under qed_vf.h just for this case [I.e., that SRIOV isn't enabled for qed].
> If all we're trying achieve is removing these gcc warnings, I think we can simply
> memset the structs in the currently-empty qed_vf_get_link_* functions.

I think both solutions are equally valid/elegant.

Arnd?
