From: =?UTF-8?Q?St=c3=a9phan_Gorget?= <sgorget@fb.com>
Subject: Re: [PATCH net-next] tcp: export drops counter to /proc/net/tcp{,6}
Date: Fri, 18 Aug 2017 13:50:50 +0100
Message-ID: <11f30e3f-b08f-373e-b952-4a5bdedc3e7d@fb.com>
References: <20170818102135.266832-1-sgorget@fb.com>
 <1503058444.4936.169.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, Jeethu Rao <jeethu@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Eric Dumazet <edumazet@google.com>, <kernel-team@fb.com>,
        <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503058444.4936.169.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/18/17 1:14 PM, Eric Dumazet wrote:
> On Fri, 2017-08-18 at 03:21 -0700, Stéphan Gorget wrote:
>> Those counters are exported for raw and udp but not for tcp, though they
>> are incremented.
>>
>> An example where it is useful is chasing listen overflow. Listen overflow
>> are counted as a global counter in LINUX_MIB_LISTENOVERFLOWS accessible
>> in /proc/net/netstat but there is no way to find related drops in the
>> information exported for tcp. With this patch it will make possible to
>> correlate growth of LINUX_MIB_LISTENOVERFLOWS with growth of drops for
>> a tcp socket.
> 
> Simply use iproute2/ss tool to access this information in a very
> efficient way (like filtering done in the kernel, instead having to
> parse a gigantic /proc output)
> 
> lpaa5:~# ss -tm state listening src :22

Thanks for the quick response, I'll use ss with those options that's
exactly what I needed.
