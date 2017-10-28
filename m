From: Christina Jacob <christina.jacob.koikara@gmail.com>
Subject: Re: [PATCH v2] xdp: Sample xdp program implementing ip forward
Date: Sat, 28 Oct 2017 19:07:32 +0530
Message-ID: <CAGSfdSi5z=LQf=AKKripUGVDgi-JXb5CgW-iuy0Xg4Z1aUMQhg@mail.gmail.com>
References: <1507620532-25804-1-git-send-email-Christina.Jacob@cavium.com>
 <1507620532-25804-2-git-send-email-Christina.Jacob@cavium.com>
 <20171010101921.30136d48@shemminger-XPS-13-9360> <d73a1229-7bb2-873c-932e-61430847ba3a@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Christina Jacob <Christina.Jacob@cavium.com>,
        daniel@iogearbox.net, Sunil.Goutham@cavium.com,
        netdev@vger.kernel.org, David Ahern <dsahern@gmail.com>,
        linux-kernel@vger.kernel.org,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        linux-arm-kernel@lists.infradead.org
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:52775 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751189AbdJ1Nhd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 09:37:33 -0400
In-Reply-To: <d73a1229-7bb2-873c-932e-61430847ba3a@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 11, 2017 at 3:07 AM, David Daney <ddaney@caviumnetworks.com> wrote:
> On 10/10/2017 10:19 AM, Stephen Hemminger wrote:
>>
>> On Tue, 10 Oct 2017 12:58:52 +0530
>> Christina Jacob <christina.jacob.koikara@gmail.com> wrote:
>>
>>> +/* Get the mac address of the interface given interface name */
>>> +static long *getmac(char *iface)
>>> +{
>>> +       int fd;
>>> +       struct ifreq ifr;
>>> +       long *mac = NULL;
>>> +
>>> +       fd = socket(AF_INET, SOCK_DGRAM, 0);
>>> +       ifr.ifr_addr.sa_family = AF_INET;
>>> +       strncpy(ifr.ifr_name, iface, IFNAMSIZ - 1);
>>> +       ioctl(fd, SIOCGIFHWADDR, &ifr);
>>> +       mac = (long *)ifr.ifr_hwaddr.sa_data;
>>> +       close(fd);
>>> +       return mac;
>>
>>
>> Always check return value of ioctl.
>> You are assuming sizeof(long) > 6 bytes.
>> Also the byte order.
>
>
>
> Also:
>
> Returning the address of a local variable (ifr.ifr_hwaddr.sa_data), and then
> dereferencing it outside of the function is not correct.
>
> The casting of the char sa_data[] to a long * may cause alignment faults on
> some architectures.  The may also be endinaness issues depending on how the
> data are manipulated if you pack all those chars into a long.
>
> If we think that a MAC address is char[6], then it may be best to define the
> data structures as such and manipulate it as an array instead of trying to
> pack it into a long.

How do I feed the MAC address to xdp.data ? Is it ok to do a manual
leftshift + biwise and  for the purpose?

>
> Keep working on this though, this program will surely be useful.
>
> David Daney
