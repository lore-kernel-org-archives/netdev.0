From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: RE: [PATCH 0/3] UCC TDM driver for MPC83xx platforms
Date: Fri, 18 Jan 2008 13:18:38 +0100
Message-ID: <1200658718.16429.26.camel@gentoo-jocke.transmode.se>
References: <FBA61160C48B8D438F3323FEFB4EF2C259F2F6@zin33exm24.fsl.freescale.net>
	<FBA61160C48B8D438F3323FEFB4EF2C26E7653@zin33exm24.fsl.freescale.net>
	<20080114120051.3207043b.kim.phillips@freescale.com>
	<20080114131530.9d33f50a.akpm@linux-foundation.org>
	<5927F7A4-D42A-40F6-AE9C-EDA34738A752@kernel.crashing.org>
	<FBA61160C48B8D438F3323FEFB4EF2C279A908@zin33exm24.fsl.freescale.net>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, Phillips Kim <Kim.Phillips@freescale.com>,
	Barkowski Michael <Michael.Barkowski@freescale.com>,
	netdev@vger.kernel.org, Suresh PV <pala@freescale.com>,
	rubini@vision.unipv.it, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Kalra Ashish <ashish.kalra@freescale.com>,
	Cutler Richard <Rich.Cutler@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Aggrwal Poonam <Poonam.Aggrwal@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <FBA61160C48B8D438F3323FEFB4EF2C279A908@zin33exm24.fsl.freescale.net>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Fri, 2008-01-18 at 17:28 +0530, Aggrwal Poonam wrote:
> Hello All
> 
> The TDM driver just now does not have a proper framework. Probably the
> interface cannot be generalised as such. Hence we could not decide
> whether it would be right to think of a TDM framework. Infact the
> interface this TDM driver(for MPC8323ERDB) supplies may not be usable
> for some other client as such. Please suggest on this.
> 
> But you are right as far as Freescale PowerPC platforms are concerned
> which have TDM devices. Like, 8315 also has a TDM driver which also
> exposes similar interface as 8323 because the client it is talking to is
> the same.
> 
> Following is the small description of the TDM driver along with
> interface details:
> 
> The dts file keeps a track of the TDM devices present on the board.
> Depending on them the TDM driver initializes those many driver instances
> while coming up.
> 
> The driver on the upper level can plug to more than one tdm clients
> depending on the availablity  of TDM devices. At every new request of
> the TDM client to bind with a TDM device, a free driver  instance is
> allocated to the client.
> 
> The interface can be described as follows.
> 
> tdm_register_client(struct tdm_client *)
> 	This API returns a pointer to the structure tdm_client which is
> of type
> 	struct tdm_client {
>                 u32 driver_handle;
>                 u32 (*tdm_read)(u32 driver_handle, short chn_id, short
> *pcm_buffer, short len);
>                 u32 (*tdm_write)(u32 driver_handle, short chn_id, short
> *pcm_buffer, short len);
>                 wait_queue_head_t *wakeup_event;
>         }
> 
>    It consists of:
>    - driver_handle: It is basically to identify the particular TDM
> device/driver instance.
>    - tdm_read: It is a function pointer returned by the TDM driver to be
> used to read TDM data  form a particular TDM channel.
>    - tdm_write: It is a function pointer returned by the TDM driver to
> be used to write TDM data  to a particular TDM channel.
>    - wakeup_event: It is address of a wait_queue event on which the
> client keeps on sleeping,  and the TDM driver wakes it up periodically.
> The driver is configured to wake up the client  after every 10ms.
> 
> Once the TDM client gets registered to a TDM driver instance and a TDM
> device, it interfaces  with the driver using tdm_read, tdm_write and
> wakeup_event.
> 
> Note: The TDM driver can be used by only kernel level modules. The
> driver does not expose any  file interface for User Applications. Can be
> compared to the spi driver which interfaces with  the SPI clients
> through some APIs.
> 
> 
> I need your feedback on the interface details. Some changes were
> suggested by Andrew for 32 bit tdm handle which I will modify.(Thanks
> Andrew)
> 
> Please give your ideas about a TDM framework in the kernel and the
> interface.
> 
> Waiting for your feedback.
> 
> Thanks and Regards
> Poonam 

Hi Poonam

I may have to write a HDLC over QMC driver for 832x in the near future.
Although I haven't looked at much at the UCCs programming i/f I noticed
that QMC is supposed to run over TDM. Is your TDM driver suitable for
hooking up such a driver on top?

  Jocke
