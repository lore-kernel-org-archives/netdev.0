From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvtap: rcu_dereference outside read-lock section
Date: Sat, 11 Aug 2012 18:16:42 -0700 (PDT)
Message-ID: <20120811.181642.1587792778007257202.davem@davemloft.net>
References: <1344679527-13377-1-git-send-email-yefremov.denis@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, jasowang@redhat.com, ebiederm@xmission.com,
	ian.campbell@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: yefremov.denis@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344679527-13377-1-git-send-email-yefremov.denis@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Efremov <yefremov.denis@gmail.com>
Date: Sat, 11 Aug 2012 14:05:27 +0400

> -		if (rcu_dereference(vlan->taps[i]) == q)
> +		if (rcu_dereference_protected(vlan->taps[i],
> +				lockdep_is_held(&macvtap_lock)) == q)

You must use the proper combination of TAB character and spaces
to line up the lockdep_is_held() argument with the first column
after openning "(" on the previous line.

Never be lazy and use only TABs.
