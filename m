From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH net-next 0/3] Allow bridge to function in
 non-promisc mode
Date: Thu, 07 Mar 2013 10:35:37 -0500
Message-ID: <5138B3C9.4060404@redhat.com>
References: <1362623485-18209-1-git-send-email-vyasevic@redhat.com>
	<CAOaVG17iZu3r9no5FtNU-6ZwW2UdR3QBE6O3EKm6-JXAmEyuyA@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAOaVG17iZu3r9no5FtNU-6ZwW2UdR3QBE6O3EKm6-JXAmEyuyA@mail.gmail.com>
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

On 03/07/2013 02:19 AM, Stephen Hemminger wrote:
> I understand the desire to add more functionality, but in this case it
> would introduce lots more problems. STP would break and it doesn't seem to
> gain anything that can't be done by other means.
>
> Turning bridge into macvlan seems unnecessary. Combining apples and bananas
> doesn't always make a tasty smoothy, sometimes it is just a mess.
>
> Maybe adding a little more to macvlan to do what you want would be simpler.
>


It's not really a macvlan over the bridge.  I would agree that 
particular setup would be a bit odd.  This work enables VMs to manage
their mac addresses and to reduce the load on the host by keeping the
bridge in promisc mode.

Sadly, most kvm network configs still use bridging and have not 
transitioned to OVS.  macvlan has some limitations as well and I working
to address those, but there is a desire for non-promisc bridge.  In
this case VMs can manage their mac addresses and can write that data to
the bridge.

STP is not broken as STP uses multicast mac and we set IFF_ALLMULTI thus
continuing to receive and process STP BPDUs.

The one thing that would appear to suffer from this is VLAN reception, 
but the bridge does allow vlan config now and that would have to be 
configured if VMs wish to use vlans.

I am not changing default operation of the bridge.  Default is still 
promisc.  In fact, one can switch back and forth without any network 
outages.  This simply adds another mode the the bridge operation.

-vlad
