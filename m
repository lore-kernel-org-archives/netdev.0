From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH 2/2] net caif:  Register properly as a pernet subsystem.
Date: Fri, 27 Jan 2012 08:24:28 -0500
Message-ID: <1327670668.14789.4.camel@lappy>
References: <4F212E7E.2040801@parallels.com>
	 <1327575108.2500.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <m1zkdacbsx.fsf@fess.ebiederm.org>
	 <20120126.180754.679593869814492219.davem@davemloft.net>
	 <m1ehumc8r4.fsf_-_@fess.ebiederm.org> <m1aa5ac8nu.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	xemul@parallels.com, sjur.brandeland@stericsson.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davej@redhat.com, sjurbren@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1aa5ac8nu.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-01-26 at 16:04 -0800, Eric W. Biederman wrote:
> caif is a subsystem and as such it needs to register with
> register_pernet_subsys instead of register_pernet_device.
> 
> Among other problems using register_pernet_device was resulting in
> net_generic being called before the caif_net structure was allocated.
> Which has been causing net_generic to fail with either BUG_ON's or by
> return NULL pointers.
> 
> A more ugly problem that could be caused is packets in flight why the
> subsystem is shutting down.
> 
> To remove confusion also remove the cruft cause by inappropriately
> trying to fix this bug.
> 
> With the aid of the previous patch I have tested this patch and
> confirmed that using register_pernet_subsys makes the failure go away
> as it should.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com> 

I've tested these two patches as well, and they also work for me.

	Tested-by: Sasha Levin <levinsasha928@gmail.com>

-- 

Sasha.
