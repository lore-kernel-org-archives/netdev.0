From: Cong Wang <cwang@twopensource.com>
Subject: Re: netconsole breaks netpoll on bridge
Date: Mon, 16 Jun 2014 12:12:06 -0700
Message-ID: <CAHA+R7Ncr_96hcTCgnxWnjXpKvW09DWMZ7J_W4n3GK0VtEo9VA@mail.gmail.com>
References: <539EE86E.6030806@profihost.ag>
	<CAHA+R7OrT+x_jvDeqKgFc=ndebhB6qwecJBcT5y0ZAA+hBCJ3Q@mail.gmail.com>
	<6B8712E6-8012-42C3-9D98-0EBD943F2894@profihost.ag>
	<CAHA+R7NUKXJhaX45+OQx3ufxrWjkjnhO84cNznbijOZWru7u6w@mail.gmail.com>
	<CE582178-E749-473F-9D88-E6D7789A3B73@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	David Miller <davem@davemloft.net>, LKML <linux-kernel@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CE582178-E749-473F-9D88-E6D7789A3B73@profihost.ag>
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

On Mon, Jun 16, 2014 at 12:05 PM, Stefan Priebe - Profihost AG
<s.priebe@profihost.ag> wrote:
>
>> Am 16.06.2014 um 20:51 schrieb Cong Wang <cwang@twopensource.com>:
>>
>> On Mon, Jun 16, 2014 at 11:41 AM, Stefan Priebe - Profihost AG
>> <s.priebe@profihost.ag> wrote:
>>>
>>>> Am 16.06.2014 um 20:05 schrieb Cong Wang <cwang@twopensource.com>:
>>>>
>>>> On Mon, Jun 16, 2014 at 5:51 AM, Stefan Priebe - Profihost AG
>>>> <s.priebe@profihost.ag> wrote:
>>>>> Hi,
>>>>>
>>>>> i'm using a vanilla 3.10.43 kernel and netconsole on top of a bridge.
>>>>>
>>>>> netconsole is used with vmbr0 (bridge) which is on top of bond0.
>>>>>
>>>>> If i want to add another bridge to vmbr0 is fails as long as netconsole
>>>>> is in use.
>>>>>
>>>>> # brctl addif vmbr0 fwpr2004p0
>>>>> can't add fwpr2004p0 to bridge vmbr0: Unknown error 524
>>>>>
>>>>> Kernel output:
>>>>> netpoll: (null): fwpr2004p0 doesn't support polling, aborting
>>>>>
>>>>> If i do rmmod netconsole - everything is working fine again.
>>>>
>>>> This is expected, you can't add an interface which doesn't support
>>>> netpoll to a bridge which is running netpoll.
>>>
>>> Thanks, so i can't use netconsole at a bridge used for vms?
>>
>> You can, but you need to make sure all the devices under
>> this bridge support netpoll. Not considering mac learning,
>> bridge just broadcasts all the packets to its ports, if one of them
>> doesn't support netpoll, how could it work?
>
> Ok i was trying to add a veth device so this is the problematic device.
>

We can just add netpoll support to veth device, it should not be hard.
I will work on it once net-next is open.

Thanks.
