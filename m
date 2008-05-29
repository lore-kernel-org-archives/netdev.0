From: "Kris Op de Beeck" <kris.op.de.beeck@newtec.eu>
Subject: Re: DNAT sporadically doesn't replace destination IP address
Date: Thu, 29 May 2008 12:12:23 +0200
Message-ID: <483E9DB9.B932.00FE.0@newtec.eu>
References: <4835A03D.B932.00FE.0@newtec.eu> <483589C0.4080006@trash.net>
 <4835ABD2.B932.00FE.0@newtec.eu> <4835913A.4020909@trash.net>
 <4835AE9B.B932.00FE.0@newtec.eu> <48359F66.50503@trash.net>
 <4836EDCE.B932.00FE.0@newtec.eu> <483AC787.6030902@trash.net>
 <483C365A.B932.00FE.0@newtec.eu> <483C1E3F.4030802@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ulrik De Bie" <ulrik.debie@newtec.eu>, <netdev@vger.kernel.org>,
	"Netfilter Development Mailinglist" <netfilter-devel@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <483C1E3F.4030802@trash.net>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 27/05/2008 at 16:44, in message <483C1E3F.4030802@trash.net>, Patrick
McHardy <kaber@trash.net> wrote:
>>     print "iptables -t mangle -A VLAN$vlan -j MARK --set-mark $vlan\n";
>>     print "iptables -t mangle -A OUTPUT -o eth2.$vlan -j VLAN$vlan\n";
>>     print "ip ro add table $vlan default dev eth2.$vlan\n";
>>     print "ip ru add fwmark $vlan table $vlan\n";
> 
> This looks like a chicken-and-egg problem. You mark packets based
> on the output device, but use the mark to direct them to the output
> device.
> 
> I guess if you use the source IP for routing table selection it
> will work. Not sure why it works at all currently.

We have found the problem why the IP addresses were not pingable anymore with Ubuntu 8.04.  It seems that with that release the rp_filter is default on.  If we put this off the modems are pingable again.  In the mean time I don't have my setup fully operational anymore. I've got 1 modem connected for the others I'm sending wget's which timeout since no modem is connected.  I nolonger see any tracing with dmesg, I will need to try again with the full setup to be sure but that will take some time.

When changing the configuration like you suggested, you get something like this for every modem:
vconfig add eth1 129
ifconfig eth1.129 192.168.1.31
route del -net 192.168.1.0/24
route add -host 10.9.9.30 eth1.129
iptables -t nat -A OUTPUT -o eth1.129 -j DNAT --to 192.168.1.1
ip ro add table 129 default dev eth1.129
ip rule add from 192.168.1.31 table 129
ip ro fl ca

Then it works also, and rp_filter can be on. This also still needs to be tested with the full setup.

I think the problem is solved. Thanks for that in guiding me.
If I should still encounter any problems I will let you know.

** Still wondering why there wasn't any problem with the old kernel ... maybe I just was lucky ...


Newtec will be present at the following exhibitions :

CommunicAsia, 17-20 June, Singapore, Booth 6B2-01

*** e-mail confidentiality footer ***
This message and any attachments thereto are confidential. They may also
be privileged or otherwise protected by work product immunity or other
legal rules. If you have received it by mistake, please let us know by
e-mail reply and delete it from your system; you may not copy this
message or disclose its contents to anyone.
E-mail transmission cannot be guaranteed to be secure or error free as
information could be intercepted, corrupted, lost, destroyed, arrive
late or incomplete, or contain viruses. The sender therefore is in no
way liable for any errors or omissions in the content of this message,
which may arise as a result of e-mail transmission. If verification is
required, please request a hard copy.

