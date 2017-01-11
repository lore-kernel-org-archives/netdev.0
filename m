From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cgroup: move CONFIG_SOCK_CGROUP_DATA to init/Kconfig
Date: Wed, 11 Jan 2017 09:48:20 -0500 (EST)
Message-ID: <20170111.094820.1988998779765372781.davem@davemloft.net>
References: <20170110120825.2984218-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, luto@kernel.org,
        augustocaringi@gmail.com, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170110120825.2984218-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 10 Jan 2017 13:08:06 +0100

> We now 'select SOCK_CGROUP_DATA' but Kconfig complains that this is
> not right when CONFIG_NET is disabled and there is no socket interface:
> 
> warning: (CGROUP_BPF) selects SOCK_CGROUP_DATA which has unmet direct dependencies (NET)
> 
> I don't know what the correct solution for this is, but simply removing
> the dependency on NET from SOCK_CGROUP_DATA by moving it out of the
> 'if NET' section avoids the warning and does not produce other build
> errors.
> 
> Fixes: 483c4933ea09 ("cgroup: Fix CGROUP_BPF config")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> There was an earlier patch by Augusto Mecking Caringi, which added
> a dependency, see https://lkml.org/lkml/2017/1/2/296.
> 
> I could not figure out whether CGROUP_BPF is meaningful without
> CONFIG_NET, my version of the patch assumes that it is.
> Applying either my version Augusto's to v4.10-rc will kill the
> warning.

CGROUP_BPF doesn't is not currently meaningful without CONFIG_NET,
and especially SOCK_CGROUP_DATA is not meaningful without CONFIG_NET.

Patch applied, thanks.
