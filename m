From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: Updated WE-18 (WPA) proposal
Date: Mon, 30 Aug 2004 09:50:26 -0700
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <20040830165026.GD29492@bougret.hpl.hp.com>
References: <20040830045441.GA7415@jm.kir.nu>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Jouni Malinen <jkmaline@cc.hut.fi>, netdev@oss.sgi.com,
	hostap@shmoo.com, Pedro Ramalhais <ramalhais@serrado.net>
Content-Disposition: inline
In-Reply-To: <20040830045441.GA7415@jm.kir.nu>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Sun, Aug 29, 2004 at 09:54:41PM -0700, Jouni Malinen wrote:
> Finally, I had enough time to implement and test the proposed WE-18
> (WPA) changes with Host AP driver and wpa_supplicant.

	Great !

> Since WE-17 has apparently not yet been merged all the way into
> linux-2.6 tree, the patch below is against Linux 2.6.8.1 that has been
> patched with WE-17 patch (http://www.hpl.hp.com/personal/
> Jean_Tourrilhes/Linux/iw268_we17-10.diff).

	Don't worry, I'll fix that. Anyway, WE-17 is pending in Jeff's
tree, and I don't think he will make major changes to it.

> - replaced optional parameter (iw_point) to SIOCSIWSCAN with a new ioctl
>   (SIOCSIWSCANEXT) since the previous design was not really backwards
>   compatible (e.g., 'iwlist wlan0 scan' did not work)

	Latest Wireless Tools actually fixes that. Most distro seems
to have adopted WT-27-preXX, and I plan to release WT-27 soon after
WE-17, so I would not consider that a big issue.
	Having a separate ioctl has one advantage, you know if the
driver support it or not. One the other hand, having a single ioctl
may reduce bloat.

> Question: is length field in struct iw_point in bytes or tokens
> (token_size bytes)? I assumed it was in bytes, but this did not work
> very well with WE ioctls that had token_size != 1; I made SIOCSIWSCANEXT
> use token_size = 1 for now, but it could be replaced to be
> sizeof(struct) and min_tokens=max_tokesn=1 once this question is
> resolved.

	Originally, I was using length == num-tokens, with token-size != 1.
	However, after a while, I realised that having length ==
num-bytes was a much better option, so that's why the "newer" ioctls
tend to all have token_size == 1.
	In the case of SIOCSIWSCANEXT, it's especially important as
the struct may grow in the future, so the size would allow to
distinguish the various additions.

	Thanks a lot !

	Jean
