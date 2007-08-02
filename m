From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 1/2] [TCP]: Also handle snd_una changes in tcp_cwnd_down
Date: Thu, 2 Aug 2007 14:18:59 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708021412380.8788@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0708012054180.27657@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-147386536-1186053539=:8788"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40098 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952AbXHBLTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 07:19:03 -0400
In-Reply-To: <Pine.LNX.4.64.0708012054180.27657@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-147386536-1186053539=:8788
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 1 Aug 2007, Ilpo Järvinen wrote:

> 
> tcp_cwnd_down must check for it too as it should be conservative
> in case of collapse stuff and also when receiver is trying to
> lie (though that wouldn't be very successful/useful anyway).
> 
> Note:
> - Separated also is_dupack and do_lost in fast_retransalert
> 	* Much cleaner look-and-feel now
> 	* This time it really fixes cumulative ACK with many new
> 	  SACK blocks recovery entry (I claimed this fixes with
> 	  last patch but it wasn't). TCP will now call
> 	  tcp_update_scoreboard regardless of is_dupack when
> 	  in recovery as long as there is enough fackets_out.
> - Introduce FLAG_SND_UNA_ADVANCED
> 	* Some prior_snd_una arguments are unnecessary after it
> - Added helper FLAG_ANY_PROGRESS to avoid long FLAG...|FLAG...
>   constructs
> 
> Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> ---
> 
> Dave, BEWARE, I wasn't able to do anything else but compile test
> because Linus' tree didn't seem to boot on the machine I was
> trying to test it... :-(
> 
> I think that to stable version only a small part of this change
> is necessary, not the full changeset. That should keep stable
> folks much happier... :-) I'll soon put my reduced proposal to:
>   http://www.cs.helsinki.fi/u/ijjarvin/patches/stable-0001.patch
> The other patch (DSACK) can go to stable as is.

I placed those two earlier sent bidir fixes and these two additional fixes 
on top of 2.6.22 and was finally able to have them tested on a bootable 
kernel (I had a boot failure on another machine too with 2.6.23-rc1 
stuff). FACK&NewReno/bidir and FACK/unidir tested, time-seq graphs were 
ok.

Dave, please put these two patches to net-2.6 to complete bidir fix 
series. ...And please push to stable as well, take just the minimized 
"fix" portion of this "[TCP]: Also handle snd_una changes in 
tcp_cwnd_down" patch as I described above. Other cleanups in it can be
put just to net-2.6.

-- 
 i.
---696243703-147386536-1186053539=:8788--
