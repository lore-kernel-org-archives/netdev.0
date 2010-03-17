From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH] drivers/net/wimax/i2400m/fw.c fix possible double free
Date: Tue, 16 Mar 2010 23:05:47 -0700
Message-ID: <1268805947.2310.1.camel@localhost.localdomain>
References: <1268739988.17270.8.camel@ICE-BOX>
	<20100316.141445.27416807.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: cindy.h.kao@intel.com, wimax@linuxwimax.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wimax@intel.com, darrenrjenkins@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <20100316.141445.27416807.davem@davemloft.net>
List-Unsubscribe: <http://lists.linuxwimax.org/options/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.linuxwimax.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://lists.linuxwimax.org/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-03-16 at 14:14 -0700, David Miller wrote: 
> From: Darren Jenkins <darrenrjenkins@gmail.com>
> Date: Tue, 16 Mar 2010 22:46:28 +1100
> 
> > i2400m_fw_check() can free i2400m->fw_hdrs if krealloc() fails causing a double free
> > Add a check so we don't free the memory a second time.
> > 
> > coverity CID: 13455
> > 
> > Signed-off-by: Darren Jenkins <darrenrjenkins@gmail.com>
> 
> Please don't fix it like this, the check is obscure and it's
> allowing other bugs to happen.
> 
> If krealloc() fails, any refrence to i2400m->fw_hdrs is
> referencing freed memory.
> 
> Therefore the krealloc() failure handling in this driver should NULL
> out i2400m->fw_hdrs and that will fix the double kfree problem as well
> as trap any stray references.

I agree with David, the fix is quite obscure. The error path in
i2400m_fw_check()'s call to i2400m_kzrealloc_2x() should be rather
cleaning up in a better way.
