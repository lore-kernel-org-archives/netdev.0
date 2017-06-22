From: Sergey Matyukevich <sergey.matyukevich.os@quantenna.com>
Subject: Re: [PATCH][net-next] qtnfmac: fix uninitialized return code in ret
Date: Thu, 22 Jun 2017 11:24:58 +0300
Message-ID: <20170622082434.nvwja6onp46vwjce@bars>
References: <20170621132530.11937-1-colin.king@canonical.com>
 <20170622051041.6vclukrzlq4zbdhm@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Colin King <colin.king@canonical.com>,
        Igor Mitsyanko <imitsyanko@quantenna.com>,
        Avinash Patil <avinashp@quantenna.com>,
        Sergey Matyukevich <smatyukevich@quantenna.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "David S . Miller" <davem@davemloft.net>,
        Bindu Therthala <btherthala@quantenna.com>,
        Kamlesh Rath <krath@quantenna.com>,
        Sergei Maksimenko <smaksimenko@quantenna.com>,
        Johannes Berg <johannes.berg@intel.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170622051041.6vclukrzlq4zbdhm@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Not related to your patch but qtnf_map_bar() should be changed not to
> return NULL.  When functions return both NULL and error pointers the
> NULL is supposed to be a special type of success return.  Here it is
> just a fail return where we forgot to set the error code to
> ERR_PTR(-ENOMEM).

Thanks for reporting! FWIW it is not a bug, all the checks of pci maps
are in place. Though having both ERR_PTR and NULL in return indeed
looks confusing. We will add a fix in the upcoming cleanup series.

Regards,
Sergey
