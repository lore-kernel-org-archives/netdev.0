From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH BUGFIX -v2 -rc4] Smack: Respect 'unlabeled' netlabel mode
Date: Sat, 31 May 2008 08:10:45 +0900
Message-ID: <200805310810.FJG69298.HtLQSVFOFMOJOF@I-love.SAKURA.ne.jp>
References: <20080530233603.GA2994@ubuntu>
	<20080530235751.GA6888@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: darwish.07@gmail.com, casey@schaufler-ca.com, paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:60629 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755878AbYE3XKu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 19:10:50 -0400
In-Reply-To: <20080530235751.GA6888@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Ahmed S. Darwish wrote:
>  	default:
> +		mutex_lock(&smack_ambient_lock);
> +		nlsp->domain = kstrdup(smack_net_ambient, GFP_ATOMIC);
> +		mutex_unlock(&smack_ambient_lock);
> +
> +		nlsp->flags = NETLBL_SECATTR_DOMAIN;
>  		break;

Getting a mutex lock might sleep, so why not use GFP_KERNEL ?
