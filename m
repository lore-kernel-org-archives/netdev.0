From: Adam Lee <adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: add MSI interrupts support
Date: Tue, 25 Mar 2014 17:13:21 +0800
Message-ID: <20140325091321.GA9241@adam-laptop>
References: <1395640841-14477-1-git-send-email-adam.lee@canonical.com>
 <1395660884-15042-1-git-send-email-adam.lee@canonical.com>
 <53304BBE.6040403@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <53304BBE.6040403-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 24, 2014 at 10:14:06AM -0500, Larry Finger wrote:
> On 03/24/2014 06:34 AM, Adam Lee wrote:
> >Add MSI interrupts support, enable it when msi_support flag is true,
> >also could fallback to pin-based interrupts mode if MSI mode fails.
> >
> >Signed-off-by: Adam Lee <adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> Your first patch turns on MSI support unconditionally. That implies that
> there are no harmful effects for attempting to use MSI on a box where it is
> not needed, and/or not implemented. If that is the case, then the
> msi_support bool should be eliminated, your first patch dropped, and this
> one revised appropriately. Driver rtl8723be added this bool, but never uses
> it. Once that driver reaches mainline, a patch can be prepared to remove the
> variable.

Hi, Larry

Just confirmed with RealTek wireless engineer, their policy is:

> Case 1: if the platform supports both MSI and Pin-based, our driver will use MSI.
> Case 2: if the platform supports MSI only, our driver will use MSI.
> Case 3: if the platform supports Pin-Based only, out driver will use Pin-Based.

I think it's safe enough to apply the first "rtlwifi: rtl8188ee: enable
MSI interrupts support" patch also, and the msi_support bool should not
be eliminated(at least for now) in case some wifi modules don't support
MSI well.

Thanks.

-- 
Adam Lee
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
