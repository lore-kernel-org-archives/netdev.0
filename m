From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 02/11] staging: r8188eu: Remove wrapper around spin_lock_bh
Date: Fri, 20 Dec 2013 10:14:08 +0300
Message-ID: <20131220071408.GK28413@mwanda>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
 <1387514323-4486-3-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1387514323-4486-3-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 19, 2013 at 10:38:34PM -0600, Larry Finger wrote:
> Some comment lines that mentioned spin_lock_bh() are also removed.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> @@ -1509,10 +1509,6 @@ _func_enter_;
>  
>  	rtw_p2p_set_state(pwdinfo, P2P_STATE_FIND_PHASE_SEARCH);
>  
> -	_enter_critical_bh(&pmlmepriv->lock, &irqL);
> -	_exit_critical_bh(&pmlmepriv->lock, &irqL);
> -
> -
>  _func_exit_;
>  }

This is a functionality change that slipped in.  This is like
spin_unlock_wait() where you want to wait until the lock is released.

In this code it's probably unintended?  But don't put these things into
a patch without mentioning it.

regards,
dan carpenter
