From: olof@lixom.net (Olof Johansson)
Subject: Re: [PATCH v2] gianfar: Add I/O barriers when touching buffer
	descriptor ownership.
Date: Fri, 4 May 2007 18:24:51 -0500
Message-ID: <20070504232451.GA15433@lixom.net>
References: <20070502195712.GA16541@ld0162-tx32.am.freescale.net>
	<F1B250DD-A472-470F-B3D0-EBB2F042E454@kernel.crashing.org>
	<4638F0C4.2000406@freescale.com>
	<FA9554A4-5A7D-4E03-BE28-C4B6B80D9DB9@kernel.crashing.org>
	<4638F734.2040809@freescale.com>
	<20070504221309.GR6193@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20070504221309.GR6193@austin.ibm.com>
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

On Fri, May 04, 2007 at 05:13:09PM -0500, Linas Vepstas wrote:
> On Wed, May 02, 2007 at 03:40:20PM -0500, Scott Wood wrote:
> > 
> > Well, Segher doesn't want me to use iobarrier (because it's not I/O). 
> > Andy doesn't want me to use wmb() (because it's sync).  I don't think 
> > something like gfar_wmb() would be appropriate.  So the remaining 
> > options are either eieio(), 
> 
> ? Just curious... the original intent of eieio was to order I/O, 
> such as MMIO; it has no effect on memory that isn't marked 
> cache-inhibited or write-trhough or guarded. Has this changed?
> I guess I haven't kept up with the times ... is eieio now
> being used to provide some other kind of barrier?
> Is eieio providing some sort of SMP synchronization side-effect?
> 
> Point being: if Segher doesn't let you "use iobarrier (because 
> it's not I/O)", then I don't understand why eieio would work (since
> that's for io only).  

Eieio has always worked for regular cachable memory as well, it just never
orders _between_ cache inhibited/guarded and cachable memory.

Book II 2.03 has a pretty good description of it on page 367.



-Olof
