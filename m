From: Maxim Uvarov <muvarov@gmail.com>
Subject: Re: [PATCH net-next v2 01/10] net: dsa: add debugfs interface
Date: Thu, 14 Sep 2017 22:59:24 +0300
Message-ID: <CAJGZr0KdOPW5_V3kvWutwTY=BJhfd-=yRDPnvbDBOCuMYWj9OQ@mail.gmail.com>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828191748.19492-2-vivien.didelot@savoirfairelinux.com>
 <20170907193434.GA11006@kroah.com> <87h8wdb8bj.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Greg KH <gregkh@linuxfoundation.org>,
        netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87h8wdb8bj.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

debugfs here is very very useful to read registers directly and
compare what use space tools see. Cool feature to get regs by port and
use standard tools to diff and print them. Even might be better to
allow drivers to decode register names and bits values. Once that is
done driver mainaince will be much easy. I.e. you need only match regs
with spec from one side and regs with user space tools from other
side. Of course it's needed only for debuging, not for production. But
even for production regs dump on something wrong might tell a lot.

Maxim.

2017-09-08 16:58 GMT+03:00 Vivien Didelot <vivien.didelot@savoirfairelinux.com>:
> Hi Greg,
>
> Greg KH <gregkh@linuxfoundation.org> writes:
>
>> I agree you shouldn't be using debugfs for this, but in the future, if
>> you do write debugfs code, please take the following review into
>> account:
>
> Humm sorry I may not have given enough details. This was really meant
> for debug and dev only, because DSA makes it hard to query directly the
> hardware (some switch ports are not exposed to userspace as well.)
>
> This is not meant to be used for anything real at all, or even be
> compiled-in in a production kernel. That's why I found it appropriate.
>
> So I am still wondering why it doesn't fit here, can you tell me why?
>
>> You should _never_ care about the return value of a debugfs call, and
>> you should not need to ever propagate the error upward.  The api was
>> written to not need this.
>>
>> Just call the function, and return, that's it.  If you need to save the
>> return value (i.e. it's a dentry), you also don't care, just save it and
>> pass it to some other debugfs call, and all will still be fine.  Your
>> code should never do anything different if a debugfs call succeeds or
>> fails.
>
> Thank for your interesting review! I'll cleanup my out-of-tree patches.
>
>
>       Vivien



-- 
Best regards,
Maxim Uvarov
