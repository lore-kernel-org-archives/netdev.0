From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix NULL pointer dereference on firmware name for
	early calls to get_drvinfo.
Date: Fri, 30 Mar 2012 20:51:54 -0400 (EDT)
Message-ID: <20120330.205154.1612043960353576031.davem@davemloft.net>
References: <1333139045-18170-1-git-send-email-notting@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org,
	inaky.perez-gonzalez@intel.com
To: notting@redhat.com
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <1333139045-18170-1-git-send-email-notting@redhat.com>
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

From: Bill Nottingham <notting@redhat.com>
Date: Fri, 30 Mar 2012 16:24:05 -0400

> The driver comments show an initialization sequence of:
>  * i2400m_setup()
>  *   i2400m->bus_setup()
>  *   i2400m_bootrom_init()
>  *   register_netdev()
>  *   wimax_dev_add()
>  *   i2400m_dev_start()
>  *     __i2400m_dev_start()
>  *       i2400m_dev_bootstrap()
> 
> dev_bootstrap() is where the firmware is loaded. So, if something calls
> get_drvinfo() from a register_netdevice_notifier (such as the cnic driver),
> we won't have a firmware name, and strncpy will crash.
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=808603
> 
> Signed-off-by: Bill Nottingham <notting@redhat.com>

Already fixed in current sources.
