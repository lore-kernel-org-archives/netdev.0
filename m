From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH PKT_SCHED 17/17]: Disable broken override bits in pedit
	action
Date: 30 Dec 2004 08:17:14 -0500
Message-ID: <1104412634.1048.106.camel@jzny.localdomain>
References: <41D378FF.3080205@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41D378FF.3080205@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-29 at 22:41, Patrick McHardy wrote:
> Disable broken override bits in pedit action. It misses
> locking and needs to allocate new memory if nkeys increases.
> Also disable it for now.
> 

There are a couple of these that you have (ipt being other). Could you
just add a check for size before returning -EOPNOTSUPP?
Example:
	if (ovr)
		if (p->nkeys != parm->nkeys)
			return -EOPNOTSUPP;

This way if they are of the same size then things should work as is
and my testcases dont break. Now if you feel more gracious, go ahead and
fix them ;->

>  	ret = -EEXIST;
>  	if (ovr) {
> +		/* FIXME: no locking, larger memory area might be required */
> +		return -EOPNOTSUPP;
>  		ret = 0;
>  override:
>  		p->flags = parm->flags;

cheers,
jamal
