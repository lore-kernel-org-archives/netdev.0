From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 07/26] brcmsmac: reduce stack size with KASAN
Date: Mon, 6 Mar 2017 12:18:33 +0100
Message-ID: <CAK8P3a12L27jXeshDngcZD9NRF5eSgsjuAwfJMXCPm4x3TU53A@mail.gmail.com>
References: <20170302163834.2273519-1-arnd@arndb.de> <20170302163834.2273519-8-arnd@arndb.de>
 <76733196-0948-8cbf-8b74-c1e3687a8c09@broadcom.com> <CAK8P3a30Ge5gyKco4HKCdKWiJk9ee1PU3_P6THjOQgHm3EQcJw@mail.gmail.com>
 <2dd6ce84-0285-b4c1-97d4-bb41a6ffec04@broadcom.com> <CAK8P3a3fNbuPvXt4M5HsXOga5Ay0yN7saewRJUoaAsXLq6AypQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kasan-dev <kasan-dev@googlegroups.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-media@vger.kernel.org,
        linux-wireless <linux-wireless@vger.kernel.org>,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>
To: Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a3fNbuPvXt4M5HsXOga5Ay0yN7saewRJUoaAsXLq6AypQ@mail.gmail.com>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 6, 2017 at 12:16 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Mon, Mar 6, 2017 at 12:02 PM, Arend Van Spriel
> <arend.vanspriel@broadcom.com> wrote:
>> On 6-3-2017 11:38, Arnd Bergmann wrote:
>>> On Mon, Mar 6, 2017 at 10:16 AM, Arend Van Spriel
>>> <arend.vanspriel@broadcom.com> wrote:

>> Given the amount of local variables maybe just tag the functions with
>> noinline instead.
>
> But that would result in less efficient object code without KASAN,
> as inlining these by default is a good idea when the stack variables
> all get folded.

Note that David Laight alread suggested renaming noinline_for_kasan
to noinline_if_stackbloat, which makes it a little more obvious what
is going on. Would that address your concern as well?

    Arnd
