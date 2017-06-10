From: =?utf-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <ne-vlezay80@yandex.ru>
Subject: =?utf-8?B?dmV0aDog0L/RgNC+0LHQu9C10LzRiyDRgdC+INGB0LrQvtGA0L7RgdGC0YzRjg==?=
Date: Sat, 10 Jun 2017 14:33:38 +0300
Message-ID: <952771497094418@web20m.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward18m.cmail.yandex.net ([5.255.216.149]:52707 "EHLO
        forward18m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751955AbdFJLl0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 07:41:26 -0400
Received: from mxback5j.mail.yandex.net (mxback5j.mail.yandex.net [IPv6:2a02:6b8:0:1619::10e])
        by forward18m.cmail.yandex.net (Yandex) with ESMTP id 175D721FEB
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 14:33:39 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Короче, имеем ядро 4.11.4. При передаче данных через veth, мы получаем скорость примерно такую:
root@containers:~# iperf3 -c 10.194.1.3
Connecting to host 10.194.1.3, port 5201
[  4] local 10.194.1.2 port 55640 connected to 10.194.1.3 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec   678 MBytes  5.68 Gbits/sec    0   1.10 MBytes       
[  4]   1.00-2.00   sec   684 MBytes  5.73 Gbits/sec    0   1.60 MBytes       
[  4]   2.00-3.00   sec   684 MBytes  5.74 Gbits/sec    0   1.60 MBytes       
[  4]   3.00-4.00   sec   686 MBytes  5.75 Gbits/sec    0   1.60 MBytes       
[  4]   4.00-5.00   sec   685 MBytes  5.75 Gbits/sec    0   1.60 MBytes       
[  4]   5.00-6.00   sec   684 MBytes  5.73 Gbits/sec    0   1.60 MBytes       
[  4]   6.00-7.00   sec   684 MBytes  5.74 Gbits/sec    0   1.60 MBytes       
[  4]   7.00-8.00   sec   684 MBytes  5.74 Gbits/sec    0   1.60 MBytes       
[  4]   8.00-9.00   sec   686 MBytes  5.75 Gbits/sec    0   1.60 MBytes       
[  4]   9.00-10.00  sec   685 MBytes  5.75 Gbits/sec    0   1.60 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec  6.68 GBytes  5.74 Gbits/sec    0             sender
[  4]   0.00-10.00  sec  6.68 GBytes  5.74 Gbits/sec                  receiver

iperf Done.

Собственно, в чём вопрос:
Какие изменения были внесины в драйвер veth? На сколько я понимаю, маленькая скорость возникает потому, что включенна проверка от плохих пакетов, которые были в этом баге: https://github.com/kubernetes/kubernetes/issues/18898

Дело в том, что veth используется также для создания псевдо туннелей, например если надо покключить в l2 режиме устройства которые не поддерживают больших пакетов к сети, в которой есть jumbo frame. 

Дело в том, что эту проверку невозможно отключить.
