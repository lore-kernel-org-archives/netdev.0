From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 13/13] scripts/checkpatch.pl: Add
 dev_kfree_skb*(NULL) check to checkpatch
Date: Sun, 03 Nov 2013 16:37:29 -0800
Message-ID: <1383525449.3042.27.camel@joe-AO722>
References: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
	 <1383400074-30555-14-git-send-email-govindarajulu90@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	schwidefsky@de.ibm.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	IvDoorn@gmail.com, sbhatewara@vmware.com, samuel@sortiz.org,
	chas@cmf.nrl.navy.mil, roland@kernel.org, isdn@linux-pingi.de,
	jcliburn@gmail.com, benve@cisco.com, ssujith@cisco.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shahed.shaikh@qlogic.com, apw@canonical.com
To: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383400074-30555-14-git-send-email-govindarajulu90@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-11-02 at 19:17 +0530, Govindarajulu Varadarajan wrote:
> Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
[]
> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
[]
> @@ -3719,7 +3719,7 @@ sub process {
>  # check for needless "if (<foo>) fn(<foo>)" uses
>  		if ($prevline =~ /\bif\s*\(\s*($Lval)\s*\)/) {
>  			my $expr = '\s*\(\s*' . quotemeta($1) . '\s*\)\s*;';
> -			if ($line =~ /\b(kfree|usb_free_urb|debugfs_remove(?:_recursive)?)$expr/) {
> +			if ($line =~ /\b(kfree|dev_kfree_skb|dev_kfree_skb_any|dev_kfree_skb_irq|usb_free_urb|debugfs_remove(?:_recursive)?)$expr/) {
>  				WARN('NEEDLESS_IF',
>  				     "$1(NULL) is safe this check is probably not required\n" . $hereprev);
>  			}

OK, but I think this is easier to read as

	dev_kfree_skb(?:_skb|_any|_irq)?
