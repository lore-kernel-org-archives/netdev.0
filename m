From: Bernhard Thaler <bernhard.thaler@wvnet.at>
Subject: Re: [PATCH] bridge: relax BR_GROUPFWD_RESTRICTED to
 forward LLDP frames
Date: Wed, 01 Apr 2015 23:03:02 +0200
Message-ID: <551C5D06.2050407@wvnet.at>
References: <1427063051-1236-1-git-send-email-bernhard.thaler@wvnet.at>	<1427666762-23683-1-git-send-email-bernhard.thaler@wvnet.at>
	<20150401.152845.1522826021699870645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Received: from 91.141.3.66.wireless.dyn.drei.com (HELO [172.16.0.2])
	(bernhard.thaler@wvnet.at@[91.141.3.66])
	(SMTPAUTH User bernhard.thaler@wvnet.at)
	(envelope-sender <bernhard.thaler@wvnet.at>)
	by smtp.wvnet.at (qmail-ldap-1.03) with SMTP
	for <netdev@vger.kernel.org>; 1 Apr 2015 21:03:11 -0000
In-Reply-To: <20150401.152845.1522826021699870645.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On 01.04.2015 21:28, David Miller wrote:
> From: Bernhard Thaler <bernhard.thaler@wvnet.at>
> Date: Mon, 30 Mar 2015 00:06:02 +0200
> 
>> BR_GROUPFWD_RESTRICTED bitmask restricts users from setting values to
>> /sys/class/net/brX/bridge/group_fwd_mask that allow forwarding of
>> some IEEE 802.1D Table 7-10 Reserved addresses:
>>
>> 	(MAC Control) 802.3		01-80-C2-00-00-01
>> 	(Link Aggregation) 802.3	01-80-C2-00-00-02
>> 	802.1AB LLDP			01-80-C2-00-00-0E
>>
>> Relax BR_GROUPFWD_RESTRICTED to at least forward LLDP frames and document
>> group_fwd_mask.
>>
>> e.g.
>>    echo 16384 > /sys/class/net/brX/bridge/group_fwd_mask
>> allows to forward LLDP frames.
>>
>> Tested on a simple bridge setup with two interfaces. Setting group_fwd_mask
>> as described above lets crafted LLDP frames traverse bridge.
>>
>> Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
> 
> I don't understand why we want to allow forwarding LLDP by default, it
> specifically is the case that an 802.1D bridge is only compliant if it
> does not forward LLDP packets.
> 
> We've blocked forwarding of LLDP by default for such a long time, so I
> argue against this change from the perspective of users expecting LLDP
> to be not forwarded by the Linux bridge by default.
> 
BR_GROUPFWD_DEFAULT is unchanged. By default none of the IEEE 802.1D
Table 7-10 Reserved addresses are forwarded by the bridge (except for
STP BPDUs if STP is turned off on the bridge device).
For users not changing /sys/class/net/brX/bridge/group_fwd_mask there
should be no difference to current default bridge behavior.

Only if users deliberately set group_fwd_mask to a value such as 16384
the bridge will start to forward LLDP frames. Current
BR_GROUPFWD_RESTRICTED value though restricts users from setting such
values to group_fwd_mask.
