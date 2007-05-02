From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH v2] gianfar: Add I/O barriers when touching buffer
	descriptor ownership.
Date: Thu, 3 May 2007 01:42:06 +0200
Message-ID: <9403063bda028d0dfe9e5a05ceea4d7a@kernel.crashing.org>
References: <20070502195712.GA16541@ld0162-tx32.am.freescale.net>
	<F1B250DD-A472-470F-B3D0-EBB2F042E454@kernel.crashing.org>
	<4638F0C4.2000406@freescale.com>
	<FA9554A4-5A7D-4E03-BE28-C4B6B80D9DB9@kernel.crashing.org>
	<4638F734.2040809@freescale.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, jgarzik@pobox.com, netdev@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <4638F734.2040809@freescale.com>
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

>>> And the driver is already ppc-specific; it uses in/out_be32.
>>
>> True, but its hidden behind the gfar_read/write accessors.
>>
>> Your change is a bit more blatant.
>
> Well, Segher doesn't want me to use iobarrier (because it's not I/O).
> Andy doesn't want me to use wmb() (because it's sync).

You should use wmb(), but unfortunately too strong
semantics are required for that (ordering wrt I/O)
so it's a full sync on PowerPC.  I don't believe
a priori that that would be notably slower, but if
actually is, you could use eieio() I suppose since
you say the driver is powerpc specific -- but please
put a comment in the source code then saying why you
don't use wmb() there.


Segher
