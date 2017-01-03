From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Tue, 3 Jan 2017 08:19:33 -0500
Message-ID: <2cd1f804-b81a-d12c-df96-59c76eecdd31@pobox.com>
References: <ed0c9790-57be-8bca-cdd6-3a54ca24f0bd@pobox.com>
 <20161125095350.GA20653@kroah.com>
 <1816ec7e-2733-f4ba-5d30-29dbabd20aad@pobox.com>
 <20161125.115827.2014848246966159357.davem@davemloft.net>
 <0835B3720019904CB8F7AA43166CEEB201057793@RTITMBSV03.realtek.com.tw>
 <CAA=3Oqn5_5w+vrg9_7UtZ-5BEbZ9Pm=qdX3WoVZKaAkxcMXYXA@mail.gmail.com>
 <CAA=3Oqn1i0cFDw1yi=vWJuU=w-N+8T7i3+xx9qQtrQCatAi+8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        "greg@kroah.com" <greg@kroah.com>,
        "romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        Ansis Atteka <aatteka@ovn.org>
To: Ansis Atteka <aatteka@nicira.com>,
        Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAA=3Oqn1i0cFDw1yi=vWJuU=w-N+8T7i3+xx9qQtrQCatAi+8Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17-01-02 07:40 PM, Ansis Atteka wrote:
..
> I think that I am getting closer to the root cause of this bug. Also,
> I have a workaround that at least makes r8152 functionally stable in
> my Dell TB15 dock. Mark, would you mind giving a chance to the patch
> that I have in the bottom of this email to see if it helps your issue
> too (you might have to tweak those settings slightly differently if
> you use something else than USB 3.0)

 /* USB_RX_EARLY_TIMEOUT */
-#define COALESCE_SUPER          85000U
-#define COALESCE_HIGH          250000U
-#define COALESCE_SLOW          524280U
+#define COALESCE_SUPER          8500U
+#define COALESCE_HIGH          25000U
+#define COALESCE_SLOW          52428U

The RTL_VER_02 chip that I was using does not support interrupt coalescing
in the driver [see the rtl8152_set_coalesce() function].  So that workaround
would not help here.
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
