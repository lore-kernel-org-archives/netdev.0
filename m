From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs
	Documentation
Date: Sat, 14 Jun 2008 10:08:08 +0200
Message-ID: <48537C68.1010207@trash.net>
References: <20080610205633.11186.45499.stgit@dale>	
	<20080610210918.11186.64253.stgit@dale>
	<484F751F.7030407@trash.net>	
	<71d336490806120850x3b5e6172jf4d75850771d6349@mail.gmail.com>	
	<485148DA.2060508@trash.net>	
	<c8028d330806121409x27a4d596k571ce87934e89371@mail.gmail.com>	
	<48529027.1090309@trash.net>
	<c8028d330806131447t2b24be93sa0e07bfa792c8f7f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org,
	poornima.kamath@qlogic.com
To: Amar Mudrankit <amar.mudrankit@qlogic.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <c8028d330806131447t2b24be93sa0e07bfa792c8f7f@mail.gmail.com>
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
>> If you have questions, feel free to ask.
>>
> I was trying to guess the use case for the vlan which has implemented
> rtnl_link api :
> 
> For sending parameters to driver:
> # ip link set <vlan-iface-name> up multicast ...... type vlan id
> <vlan-id> reorder_hdr on
> 
> ingress-qos-map <...> egress-qos-map <...>
> 
> In such case, I think the link_util's private parse_opt function will
> be invoked to parse link's private configurable parameters.  These
> parameters along with the standard set of parameters (name, multicast,
> promisc etc) are then sent to driver through rtnl_talk function .
> 
> Similarly, for reading values from driver:
> 
> # ip addr show dev <vlan-iface-name>
> 
> does it require "type" field similar to "ip link set"?

No. Thats only required for parsing device specific parameters.

> Is this understanding correct?

Yes.

> How does a link type corresponding to VLAN driver gets added into
> linkutil_list, so that ip will correctly call functions specific to
> VLAN driver?

iproute dlopens itself and looks for the struct "<type>_link_util".

>> You can dump driver private statistics in the ->fill_xstats function.
>>
> 
> I was looking at latest release of iproute2, in which I could not
> locate fill_xstats. Can you help me to locate this?

->fill_xstats is in the kernel, in iproute its ->print_xstats.
