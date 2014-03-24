From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/core: Use RCU_INIT_POINTER(x, NULL) in netpoll.c
Date: Mon, 24 Mar 2014 06:14:35 -0700
Message-ID: <1395666875.12610.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395601966-12490-1-git-send-email-monamagarwal123@gmail.com>
	 <20140324111144.GA19368@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Monam Agarwal <monamagarwal123@gmail.com>, davem@davemloft.net,
	ebiederm@xmission.com, cwang@twopensource.com, kaber@trash.net,
	antonio@meshcoding.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140324111144.GA19368@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-03-24 at 07:11 -0400, Neil Horman wrote:
> On Mon, Mar 24, 2014 at 12:42:46AM +0530, Monam Agarwal wrote:
> > This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)
> > 
> > The rcu_assign_pointer() ensures that the initialization of a structure       
> > is carried out before storing a pointer to that structure. 
> > And in the case of the NULL pointer, there is no structure to initialize. 
> > So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)
> > 
> > Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
> No, I don't think this is right. __netpoll_cleanup can be called in parallel
> with bottom half access to dev->npinfo.  rcu_assign pointer is safe against
> those accesses, but RCU_INIT_POINTER is not.

Wow, it is always safe for NULL value.
