From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] qed: fix qed_fill_link() error handling
Date: Mon, 30 May 2016 16:24:07 +0000
Message-ID: <CO2PR11MB00881A57063B9AB617359A9097450@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1464623197-2084229-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464623197-2084229-1-git-send-email-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +	if (IS_ENABLED(CONFIG_QED_SRIOV) && !IS_PF(hwfn->cdev)) {
> +		qed_vf_get_link_params(hwfn, params);
> +		qed_vf_get_link_state(hwfn, link);
> +		qed_vf_get_link_caps(hwfn, link_caps);
> +
> +		return 0;
> +	}

The IS_ENABLED here seems a bit wasteful to me - we have empty implementation
under qed_vf.h just for this case [I.e., that SRIOV isn't enabled for qed].
If all we're trying achieve is removing these gcc warnings, I think we can simply
memset the structs in the currently-empty qed_vf_get_link_* functions.
