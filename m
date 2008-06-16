From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs
	Documentation
Date: Mon, 16 Jun 2008 22:39:19 +0200
Message-ID: <4856CF77.8010705@trash.net>
References: <20080610205633.11186.45499.stgit@dale>	
	<20080610210918.11186.64253.stgit@dale>
	<484F751F.7030407@trash.net>	
	<71d336490806120850x3b5e6172jf4d75850771d6349@mail.gmail.com>	
	<485148DA.2060508@trash.net>	
	<c8028d330806121409x27a4d596k571ce87934e89371@mail.gmail.com>	
	<48529027.1090309@trash.net>	
	<c8028d330806131447t2b24be93sa0e07bfa792c8f7f@mail.gmail.com>	
	<48537C68.1010207@trash.net>
	<c8028d330806161244j5a7f46e8y898deea69751d4f6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org,
	poornima.kamath@qlogic.com
To: Amar Mudrankit <amar.mudrankit@qlogic.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <c8028d330806161244j5a7f46e8y898deea69751d4f6@mail.gmail.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Amar Mudrankit wrote:
>>> I was looking at latest release of iproute2, in which I could not
>>> locate fill_xstats. Can you help me to locate this?
>> ->fill_xstats is in the kernel, in iproute its ->print_xstats.
> 
> I was looking at kernel code net/8021q/vlan_netlink.c on which I have
> following queries:
> 
> a.  Is it a correct file in kernel I m referring to?

Yes.

> b.  vlan_fill_info is a function to send parameters back to user
> level. What is the role of skb as an argument to function? Is some
> network operation expected?

netlink is a (local) networking protocol, this is the message
sent to userspace.

> c.  How exactly the kernel API ops->get_size comes into play? I guess
> user prog should first get the size of parameters that will be
> returned by driver before calling ops->fill_info.

No, its used internally for skb allocation. It should return
the size of all encapsulated netlink attributes that will be
dumped by ->fill_info (in most cases, just a constant value).

> d.  Can somebody briefly introduce struct nlattr? It looks like all
> parameters flow through this structure.

Not much to say about it, nla_type contains the numerical
attribute type, nla_len the length without padding. Data
follows the attribute, followed by padding to a multiple
of four. The netlink construction functions and macros
from include/net/netlink.h take care of all of this for
you.
