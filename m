From: Luca Coelho <luca@coelho.fi>
Subject: Re: [PATCH] iwlwifi: mvm: fix iwl_mvm_sar_find_wifi_pkg corner case
Date: Wed, 28 Jun 2017 14:59:33 +0300
Message-ID: <1498651173.22048.111.camel@coelho.fi>
References: <20170627152458.1103403-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Intel Linux Wireless <linuxwifi@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Sara Sharon <sara.sharon@intel.com>,
        Golan Ben-Ami <golan.ben.ami@intel.com>,
        Liad Kaufman <liad.kaufman@intel.com>,
        Haim Dreyfuss <haim.dreyfuss@intel.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>,
        Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from paleale.coelho.fi ([176.9.41.70]:35604 "EHLO
        farmhouse.coelho.fi" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751652AbdF1L7o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 07:59:44 -0400
In-Reply-To: <20170627152458.1103403-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-06-27 at 17:24 +0200, Arnd Bergmann wrote:
> gcc warns about what it thinks is an uninitialized variable
> access:
> 
> drivers/net/wireless/intel/iwlwifi/mvm/fw.c: In function 'iwl_mvm_sar_find_wifi_pkg.isra.14':
> drivers/net/wireless/intel/iwlwifi/mvm/fw.c:1102:5: error: 'wifi_pkg' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> That problem cannot really happen, as we check data->package.count
> to ensure that the loop is entered at least once.
> However, something that can indeed happen is returning an incorrect
> wifi_pkg pointer in case none of the elements are what we are looking
> for.
> 
> This modifies the loop again, to only return a correct object, and
> to shut up that warning.
> 
> Fixes: c386dacb4ed6 ("iwlwifi: mvm: refactor SAR init to prepare for dynamic SAR")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---

Thanks, Arnd!

I've pushed this to our internal tree and it will eventually reach the
mainline, via our normal upstreaming process.
