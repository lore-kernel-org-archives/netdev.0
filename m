From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Tue, 28 Apr 2009 23:11:36 +0200
Message-ID: <49F77108.7060509@cosmosbay.com>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com> <49F3308B.1030507@cosmosbay.com> <20090426.020411.157511269.davem@davemloft.net> <49F43B8F.2050907@cosmosbay.com> <87ab60rh8t.fsf@basil.nowhere.org> <49F71B63.8010503@cosmosbay.com> <alpine.DEB.1.10.0904281501300.13862@qirst.com> <49F76174.6060009@cosmosbay.com> <alpine.DEB.1.10.0904281612560.13862@qirst.com> <49F767FD.2040205@cosmosbay.com> <alpine.DEB.1.10.0904281629090.15947@qirst.com> <49F76F6C.80005@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, haoki@redhat.com, mchan@broadcom.com,
	davidel@xmailserver.org, Ingo Molnar <mingo@elte.hu>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756521AbZD1VNi@vger.kernel.org>
In-Reply-To: <49F76F6C.80005@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
> Christoph Lameter a =E9crit :
>> On Tue, 28 Apr 2009, Eric Dumazet wrote:
>>
>>> The one that did improved your udpping 'bench' :)
>>>
>>> http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3D=
commitdiff;h=3Dbf368e4e70cd4e0f880923c44e95a4273d725ab4
>> Well yes that is git2p1. The measurements that we took showed not mu=
ch of
>> an effect as you see.
>>
>=20
> It depends of coalescing parameters of NIC.
>=20
> BNX2 interrupts first handle TX completions, then RX events.
> So If by the
>=20

Sorry for the previous message...

If by the time interrupt comes to the host, TX was handled right before=
 RX event,
the extra wakeup is not a problem, because incoming frame will be deliv=
ered into
socket queue right before awaken thread tries to pull it.

On real workloads (many incoming/outgoing frames), then avoiding extra =
wakeups is
a win, regardless of coalescing parameters and cpu affinities...

On uddpping, I had prior to the patch about 49000 wakeups per second,
and after patch about 26000 wakeups per second (matches number of incom=
ing
udp messages per second)
