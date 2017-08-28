From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 01/10] net: dsa: add debugfs interface
Date: Mon, 28 Aug 2017 12:58:12 -0700
Message-ID: <b642a93c-1f63-522d-e9f2-c266b809623a@gmail.com>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828191748.19492-2-vivien.didelot@savoirfairelinux.com>
 <20170828195039.GA1950@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828195039.GA1950@nanopsycho.orion>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/28/2017 12:50 PM, Jiri Pirko wrote:
> Mon, Aug 28, 2017 at 09:17:39PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>> This commit adds a DEBUG_FS dependent DSA core file creating a generic
>> debug filesystem interface for the DSA switch devices.
>>
>> The interface can be mounted with:
>>
>>    # mount -t debugfs none /sys/kernel/debug
>>
>> The dsa directory contains one directory per switch chip:
>>
>>    # cd /sys/kernel/debug/dsa/
>>    # ls
>>    switch0  switch1 switch2
>>
>> Each chip directory contains one directory per port:
>>
>>    # ls -l switch0/
>>    drwxr-xr-x 2 root root 0 Jan  1 00:00 port0
>>    drwxr-xr-x 2 root root 0 Jan  1 00:00 port1
>>    drwxr-xr-x 2 root root 0 Jan  1 00:00 port2
>>    drwxr-xr-x 2 root root 0 Jan  1 00:00 port5
>>    drwxr-xr-x 2 root root 0 Jan  1 00:00 port6
>>
>> Future patches will add entry files to these directories.
>>
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> Oh no, no debugfs please!
> 
> What do you need to expose? I'm sure we can find out some generic, well
> defined and reusable way.

We have no CPU or DSA (cross switches) net_device reprensentors because
those would be two ends of the same pipe so it would be both confusing
and a duplication. For a CPU interface, one side goes to the switch, the
other one is the master net_device (normal Ethernet MAC). For a DSA
interface, one interface is on one switch, and the other is on the other
switch.

If you look at the patch series it's pretty obvious what is being exposed :)
-- 
Florian
