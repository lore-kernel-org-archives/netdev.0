From: Robert Milasan <rmilasan@suse.com>
Subject: Re: "tuntap: multiqueue support" causes udev fork bombs
Date: Wed, 28 Nov 2012 11:30:43 +0100
Message-ID: <20121128113043.39a56f22@coolcat.suse.cz>
References: <50B5E6A5.6040009@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, "David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Jiri Slaby <jirislaby@gmail.com>, maxk@qualcomm.com
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50B5E6A5.6040009@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Nov 2012 11:25:41 +0100
Jiri Slaby <jslaby@suse.cz> wrote:

> Hi,
> 
> with this commit:
> commit c8d68e6be1c3b242f1c598595830890b65cea64a
> Author: Jason Wang <jasowang@redhat.com>
> Date:   Wed Oct 31 19:46:00 2012 +0000
> 
>     tuntap: multiqueue support
> 
> 
> I see fork bombs from udev. It is trying to create 2048 processes.
> 1024 for tx, 1024 for rx. OOM killer indeed steps in and kills
> everything.
> 
> To trigger that it's enough for me to the following on a 6G of RAM
> machine: # echo 3 >/proc/sys/vm/drop_caches
> # /etc/init.d/openvpn restart
> 
> [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj
> name [  987]     0   987    11453     2276      28        0
> -1000 systemd-udevd
> [  992]     0   992   487336      102     783        0             0
> systemd-journal
> [ 1877]     0  1877    36866      277      42        0             0
> cupsd [ 1881]    81  1881     7677      236      20        0
> -900 dbus-daemon
> [ 1894]     0  1894     7525       67      19        0             0
> rpcbind [ 1900]     0  1900     1860      809       8
> 0             0 haveged [ 1902]     0  1902     8647       83
> 23        0             0 systemd-logind
> [ 1918]    99  1918     4567      100      13        0             0
> ksysguardd
> [ 1919]     0  1919    55276      258      42        0             0
> upowerd [ 1942]   106  1942   104395     1835      76
> 0             0 pulseaudio
> [ 1947]   117  1947    67472      423      33        0             0
> polkitd [ 1991]     0  1991    22199       39      13
> 0             0 agetty [ 2034]     0  2034    22199       39
> 13        0             0 agetty [ 2080]     0  2080    22199
> 39      13        0             0 agetty [ 2105]     0  2105
> 22199       37      13        0             0 agetty [ 2150]     0
> 2150    22199       39      13        0             0 agetty
> [ 4118]     0  4118     2132       34       8        0             0
> dhcpcd [ 4319]     0  4319    24629      153      17
> 0             0 cron [ 4339]     0  4339    95072      620
> 28        0             0 automount [ 4340]     0  4340    15100
> 187      32        0             0 nmbd [ 4377]     0  4377
> 13038      147      29        0         -1000 sshd [ 4719]    25
> 4719    65189     4833      56        0             0 named
> [ 4776]     8  4776    12262      144      25        0             0
> exim [ 4792]   498  4792   200033     2915     140
> 0             0 mpd [ 4798]     0  4798    22239      515
> 46        0             0 httpd2-prefork [ 4799]    30  4799
> 22267      544      45        0             0 httpd2-prefork
> [ 4800]     0  4800    22199       38      13        0             0
> agetty [ 8480]    38  8480     8886      152      22
> 0             0 ntpd [ 9210]     0  9210    19982      229
> 41        0             0 winbindd
> [ 9236]     0  9236    41560      271      46        0             0
> smbd [ 9241]     0  9241     6148       51      17
> 0             0 kdm [ 9258]     0  9258    50350    18924
> 102        0             0 Xorg [ 9265]     0  9265    17737
> 126      40        0             0 kdm [ 9275]     0  9275
> 20006      233      40        0             0 winbindd
> [ 9276]     0  9276    20009      234      40        0             0
> winbindd
> [ 9277]     0  9277    19982      229      39        0             0
> winbindd
> [ 9278]     0  9278    41595      271      44        0             0
> smbd [ 9286]   500  9286     3212       32      12
> 0             0 ck-launch-sessi
> [ 9334]     0  9334   261302      767      44        0             0
> console-kit-dae
> [ 9402]   500  9402    21982       80      13        0             0
> startkde
> [ 9405]   500  9405     5569       71      14        0             0
> dbus-launch
> [ 9406]   500  9406     7934      351      18        0             0
> dbus-daemon
> [ 9407]   500  9407    22464       52      11        0             0
> gpg-agent
> [ 9408]   500  9408     3116       79       9        0             0
> ssh-agent
> [ 9447]   500  9447     1021       21       6        0          -300
> start_kdeinit
> [ 9448]   500  9448    95847     1417     135        0          -300
> kdeinit4
> [ 9449]   500  9449    97074     1400     128        0             0
> klauncher
> [ 9451]   500  9451   217312     3643     232        0             0
> kded4 [ 9454]   500  9454     5613       71      16
> 0             0 gam_server
> [ 9461]   500  9461   118346     2242     166        0             0
> kglobalaccel
> [ 9465]   500  9465   106352     1222     127        0             0
> kactivitymanage
> [ 9468]     0  9468    86882      348      39        0             0
> udisksd [ 9474]   500  9474     1055       19       7
> 0             0 kwrapper4
> [ 9475]   500  9475   139558     1967     173        0             0
> ksmserver
> [ 9479]   500  9479   274661     3121     206        0             0
> knotify4
> [ 9481]   500  9481   197330     8264     225        0             0
> kwin [ 9489]   500  9489   247392    15943     293
> 0             0 plasma-desktop
> [ 9496]   500  9496     2462       94      10        0             0
> ksysguardd
> [ 9503]   500  9503    80747      985     123        0             0
> kuiserver
> [ 9506]   500  9506    49217      363      30        0             0
> akonadi_control
> [ 9508]   500  9508   319188     1502      70        0             0
> akonadiserver
> [ 9515]   500  9515    87701      848     101        0             0
> akonadi_agent_l
> [ 9517]   500  9517    87701      848      99        0             0
> akonadi_agent_l
> [ 9518]   500  9518    86733      840     100        0             0
> akonadi_agent_l
> [ 9519]   500  9519    86733      836      96        0             0
> akonadi_agent_l
> [ 9520]   500  9520    86733      839     104        0             0
> akonadi_agent_l
> [ 9521]   500  9521    86733      835      98        0             0
> akonadi_agent_l
> [ 9522]   500  9522    86649     1050     130        0             0
> akonadi_kabc_re
> [ 9523]   500  9523    87700      848     102        0             0
> akonadi_agent_l
> [ 9524]   500  9524    96933     1146     149        0             0
> akonadi_maildis
> [ 9526]   500  9526    86307     1039     130        0             0
> akonadi_nepomuk
> [ 9541]   500  9541    86080      827      98        0             0
> akonadi_agent_l
> [ 9542]   500  9542    86076      826      98        0             0
> akonadi_agent_l
> [ 9569]   500  9569   258392     4518     237        0             0
> krunner [ 9581]   500  9581    41396     6834      50
> 0             0 xterm [ 9593]   500  9593   179383     3144
> 187        0             0 kmix [ 9596]   500  9596    24871
> 824      19        0             0 bash [ 9601]   500  9601
> 83376      959     122        0             0 nepomukcontroll
> [ 9612]   500  9612    35918     1357      40        0             0
> xterm [ 9613]   500  9613   394605    78575     507
> 0             0 firefox [ 9617]   500  9617    24819      769
> 17        0             0 bash [ 9639]   500  9639   219529
> 3667     167        0             0 gmpc [ 9642]   500  9642
> 322588    29782     310        0             0 thunderbird-bin
> [ 9670]   500  9670    98277      518      78        0             0
> zeitgeist-datah
> [ 9674]   500  9674   106065     1042     134        0             0
> polkit-kde-auth
> [ 9677]   500  9677   121823     1986     172        0             0
> klipper [ 9685]   500  9685    84864      719      34
> 0             0 zeitgeist-daemo
> [ 9693]   500  9693    51569      231      36        0             0
> zeitgeist-fts
> [ 9697]   500  9697    66883      126      32        0             0
> gvfsd [ 9708]   500  9708    20166       23      10
> 0             0 cat [ 9729]   500  9729    32115      625
> 31        0             0 gconfd-2
> [ 9755]   500  9755    46906      117      30        0             0
> at-spi-bus-laun
> [ 9770]   500  9770    83934     1051     125        0             0
> kmozillahelper
> [10343]    30 10343    22265      542      45        0             0
> httpd2-prefork
> [10347]    30 10347    22265      541      45        0             0
> httpd2-prefork
> [10348]    30 10348    22267      545      45        0             0
> httpd2-prefork
> [10354]    30 10354    22267      544      45        0             0
> httpd2-prefork
> [10355]    30 10355    22267      543      45        0             0
> httpd2-prefork
> [10356]    30 10356    22267      544      45        0             0
> httpd2-prefork
> [10357]    30 10357    22267      544      45        0             0
> httpd2-prefork
> [10409]   500 10409    34921      136      37        0             0
> su [10421]     0 10421    24642      600      19        0
> 0 bash [10522]   500 10522   486624     5871     185
> 0             0 psi-plus
> [11743]   500 11743    35919     1358      38        0             0
> xterm [11745]   500 11745    24871      810      19
> 0             0 bash [11767]   500 11767    34922      136
> 37        0             0 su [11779]   502 11779    24583
> 543      18        0             0 bash [12412]   500 12412
> 35919     1358      39        0             0 xterm [12414]   500
> 12414    24871      824      19        0             0 bash
> [17530]     0 17530    63856      103      24        0             0
> rsyslogd [22468]   500 22468   117093     1537     133
> 0             0 kio_trash
> [22469]   500 22469    98653     1464     130        0             0
> kio_file
> [22699]     0 22699    15508      391      33        0             0
> openvpn [22718]     0 22718     9505      360      22
> 0             0 systemd-udevd
> [26825]     0 26825    11353     2198      26        0             0
> systemd-udevd
> [26826]     0 26826    11353     2198      26        0             0
> systemd-udevd
> [26827]     0 26827    11353     2198      26        0             0
> systemd-udevd
> [26828]     0 26828    11353     2198      26        0             0
> systemd-udevd
> [26829]     0 26829    11353     2198      26        0             0
> systemd-udevd
> [26830]     0 26830    11353     2198      26        0             0
> systemd-udevd
> [26831]     0 26831    11353     2198      26        0             0
> systemd-udevd
> [26832]     0 26832    11353     2199      26        0             0
> systemd-udevd
> [26833]     0 26833    11353     2199      26        0             0
> systemd-udevd
> [26834]     0 26834    11353     2199      26        0             0
> systemd-udevd
> [26835]     0 26835    11353     2199      26        0             0
> systemd-udevd
> [26836]     0 26836    11353     2199      26        0             0
> systemd-udevd
> [26837]     0 26837    11353     2199      26        0             0
> systemd-udevd
> [26838]     0 26838    11353     2199      26        0             0
> systemd-udevd
> [26839]     0 26839    11353     2199      26        0             0
> systemd-udevd
> [26840]     0 26840    11353     2200      26        0             0
> systemd-udevd
> [26841]     0 26841    11353     2200      26        0             0
> systemd-udevd
> [26842]     0 26842    11353     2200      26        0             0
> systemd-udevd
> [26843]     0 26843    11353     2200      26        0             0
> systemd-udevd
> [26844]     0 26844    11353     2200      26        0             0
> systemd-udevd
> [26845]     0 26845    11353     2200      26        0             0
> systemd-udevd
> [26846]     0 26846    11353     2200      26        0             0
> systemd-udevd
> [26847]     0 26847    11353     2201      26        0             0
> systemd-udevd
> [26848]     0 26848    11353     2201      26        0             0
> systemd-udevd
> [26849]     0 26849    11353     2201      26        0             0
> systemd-udevd
> [26850]     0 26850    11353     2201      26        0             0
> systemd-udevd
> [26851]     0 26851    11353     2201      26        0             0
> systemd-udevd
> [26852]     0 26852    11353     2201      26        0             0
> systemd-udevd
> [26853]     0 26853    11353     2201      26        0             0
> systemd-udevd
> [26854]     0 26854    11353     2202      26        0             0
> systemd-udevd
> [26855]     0 26855    11353     2202      26        0             0
> systemd-udevd
> [26856]     0 26856    11353     2202      26        0             0
> systemd-udevd
> [26857]     0 26857    11353     2202      26        0             0
> systemd-udevd
> [26858]     0 26858    11353     2202      26        0             0
> systemd-udevd
> [26859]     0 26859    11353     2202      26        0             0
> systemd-udevd
> [26860]     0 26860    11353     2202      26        0             0
> systemd-udevd
> [26861]     0 26861    11353     2203      26        0             0
> systemd-udevd
> [26862]     0 26862    11353     2203      26        0             0
> systemd-udevd
> [26863]     0 26863    11353     2203      26        0             0
> systemd-udevd
> [26864]     0 26864    11353     2203      26        0             0
> systemd-udevd
> [26865]     0 26865    11353     2203      26        0             0
> systemd-udevd
> [26866]     0 26866    11353     2203      26        0             0
> systemd-udevd
> [26867]     0 26867    11353     2204      26        0             0
> systemd-udevd
> [26868]     0 26868    11353     2204      26        0             0
> systemd-udevd
> [26869]     0 26869    11353     2204      26        0             0
> systemd-udevd
> [26870]     0 26870    11353     2204      26        0             0
> systemd-udevd
> [26871]     0 26871    11353     2204      26        0             0
> systemd-udevd
> [26872]     0 26872    11353     2204      26        0             0
> systemd-udevd
> [26873]     0 26873    11353     2204      26        0             0
> systemd-udevd
> [26874]     0 26874    11353     2205      26        0             0
> systemd-udevd
> [26875]     0 26875    11353     2205      26        0             0
> systemd-udevd
> [26876]     0 26876    11353     2205      26        0             0
> systemd-udevd
> [26877]     0 26877    11353     2205      26        0             0
> systemd-udevd
> [26878]     0 26878    11353     2205      26        0             0
> systemd-udevd
> [26879]     0 26879    11353     2205      26        0             0
> systemd-udevd
> [26880]     0 26880    11353     2205      26        0             0
> systemd-udevd
> [26881]     0 26881    11353     2206      26        0             0
> systemd-udevd
> [26882]     0 26882    11353     2206      26        0             0
> systemd-udevd
> [26883]     0 26883    11353     2206      26        0             0
> systemd-udevd
> [26884]     0 26884    11353     2206      26        0             0
> systemd-udevd
> [26885]     0 26885    11353     2206      26        0             0
> systemd-udevd
> [26886]     0 26886    11353     2206      26        0             0
> systemd-udevd
> [26887]     0 26887    11353     2206      26        0             0
> systemd-udevd
> [26888]     0 26888    11386     2207      26        0             0
> systemd-udevd
> [26889]     0 26889    11386     2207      26        0             0
> systemd-udevd
> [26890]     0 26890    11386     2207      26        0             0
> systemd-udevd
> [26891]     0 26891    11386     2207      26        0             0
> systemd-udevd
> [26892]     0 26892    11386     2207      26        0             0
> systemd-udevd
> [26893]     0 26893    11386     2207      26        0             0
> systemd-udevd
> [26894]     0 26894    11386     2208      26        0             0
> systemd-udevd
> [26895]     0 26895    11386     2208      26        0             0
> systemd-udevd
> [26896]     0 26896    11386     2208      26        0             0
> systemd-udevd
> [26897]     0 26897    11386     2208      26        0             0
> systemd-udevd
> [26898]     0 26898    11386     2208      26        0             0
> systemd-udevd
> [26899]     0 26899    11386     2208      26        0             0
> systemd-udevd
> [26900]     0 26900    11386     2208      26        0             0
> systemd-udevd
> [26901]     0 26901    11386     2209      26        0             0
> systemd-udevd
> [26902]     0 26902    11386     2209      26        0             0
> systemd-udevd
> [26903]     0 26903    11386     2209      26        0             0
> systemd-udevd
> [26904]     0 26904    11386     2209      26        0             0
> systemd-udevd
> [26905]     0 26905    11386     2209      26        0             0
> systemd-udevd
> [26906]     0 26906    11386     2209      26        0             0
> systemd-udevd
> [26907]     0 26907    11386     2209      26        0             0
> systemd-udevd
> [26908]     0 26908    11386     2210      26        0             0
> systemd-udevd
> [26909]     0 26909    11386     2210      26        0             0
> systemd-udevd
> [26910]     0 26910    11386     2210      26        0             0
> systemd-udevd
> [26911]     0 26911    11386     2210      26        0             0
> systemd-udevd
> [26912]     0 26912    11386     2210      26        0             0
> systemd-udevd
> [26913]     0 26913    11386     2210      26        0             0
> systemd-udevd
> [26914]     0 26914    11386     2210      26        0             0
> systemd-udevd
> [26915]     0 26915    11386     2211      26        0             0
> systemd-udevd
> [26916]     0 26916    11386     2211      26        0             0
> systemd-udevd
> [26917]     0 26917    11386     2211      26        0             0
> systemd-udevd
> [26918]     0 26918    11386     2211      26        0             0
> systemd-udevd
> [26919]     0 26919    11386     2211      26        0             0
> systemd-udevd
> [26920]     0 26920    11386     2211      26        0             0
> systemd-udevd
> [26921]     0 26921    11386     2212      26        0             0
> systemd-udevd
> [26922]     0 26922    11386     2212      26        0             0
> systemd-udevd
> [26923]     0 26923    11386     2212      26        0             0
> systemd-udevd
> [26924]     0 26924    11386     2212      26        0             0
> systemd-udevd
> [26925]     0 26925    11386     2212      26        0             0
> systemd-udevd
> [26926]     0 26926    11386     2212      26        0             0
> systemd-udevd
> [26927]     0 26927    11386     2212      26        0             0
> systemd-udevd
> [26928]     0 26928    11386     2213      26        0             0
> systemd-udevd
> [26929]     0 26929    11386     2213      26        0             0
> systemd-udevd
> [26930]     0 26930    11386     2213      26        0             0
> systemd-udevd
> [26931]     0 26931    11386     2213      26        0             0
> systemd-udevd
> [26932]     0 26932    11386     2213      26        0             0
> systemd-udevd
> [26933]     0 26933    11386     2213      26        0             0
> systemd-udevd
> [26934]     0 26934    11386     2213      26        0             0
> systemd-udevd
> [26935]     0 26935    11386     2214      26        0             0
> systemd-udevd
> [26936]     0 26936    11386     2214      26        0             0
> systemd-udevd
> [26937]     0 26937    11386     2214      26        0             0
> systemd-udevd
> [26938]     0 26938    11386     2214      26        0             0
> systemd-udevd
> [26939]     0 26939    11386     2214      26        0             0
> systemd-udevd
> [26940]     0 26940    11386     2214      26        0             0
> systemd-udevd
> [26941]     0 26941    11386     2215      26        0             0
> systemd-udevd
> [26942]     0 26942    11386     2215      26        0             0
> systemd-udevd
> [26943]     0 26943    11386     2215      26        0             0
> systemd-udevd
> [26944]     0 26944    11386     2215      26        0             0
> systemd-udevd
> [26945]     0 26945    11386     2215      26        0             0
> systemd-udevd
> [26946]     0 26946    11386     2215      26        0             0
> systemd-udevd
> [26947]     0 26947    11386     2215      26        0             0
> systemd-udevd
> [26948]     0 26948    11386     2216      26        0             0
> systemd-udevd
> [26949]     0 26949    11386     2216      26        0             0
> systemd-udevd
> [26950]     0 26950    11386     2216      26        0             0
> systemd-udevd
> [26951]     0 26951    11386     2216      26        0             0
> systemd-udevd
> [26952]     0 26952    11386     2216      26        0             0
> systemd-udevd
> [26953]     0 26953    11386     2216      26        0             0
> systemd-udevd
> [26954]     0 26954    11386     2216      26        0             0
> systemd-udevd
> [26955]     0 26955    11386     2217      26        0             0
> systemd-udevd
> [26956]     0 26956    11386     2217      26        0             0
> systemd-udevd
> [26957]     0 26957    11386     2217      26        0             0
> systemd-udevd
> [26958]     0 26958    11386     2217      26        0             0
> systemd-udevd
> [26959]     0 26959    11386     2217      26        0             0
> systemd-udevd
> [26960]     0 26960    11386     2217      26        0             0
> systemd-udevd
> [26961]     0 26961    11386     2217      26        0             0
> systemd-udevd
> [26962]     0 26962    11386     2218      26        0             0
> systemd-udevd
> [26963]     0 26963    11386     2218      26        0             0
> systemd-udevd
> [26964]     0 26964    11386     2218      26        0             0
> systemd-udevd
> [26965]     0 26965    11386     2218      26        0             0
> systemd-udevd
> [26966]     0 26966    11386     2218      26        0             0
> systemd-udevd
> [26967]     0 26967    11386     2218      26        0             0
> systemd-udevd
> [26968]     0 26968    11386     2219      26        0             0
> systemd-udevd
> [26969]     0 26969    11386     2219      26        0             0
> systemd-udevd
> [26970]     0 26970    11386     2219      26        0             0
> systemd-udevd
> [26971]     0 26971    11386     2219      26        0             0
> systemd-udevd
> [26972]     0 26972    11386     2219      26        0             0
> systemd-udevd
> [26973]     0 26973    11386     2219      26        0             0
> systemd-udevd
> [26974]     0 26974    11386     2219      26        0             0
> systemd-udevd
> [26975]     0 26975    11386     2220      26        0             0
> systemd-udevd
> [26976]     0 26976    11386     2220      26        0             0
> systemd-udevd
> [26977]     0 26977    11386     2220      26        0             0
> systemd-udevd
> [26978]     0 26978    11386     2220      26        0             0
> systemd-udevd
> [26979]     0 26979    11386     2220      26        0             0
> systemd-udevd
> [26980]     0 26980    11386     2220      26        0             0
> systemd-udevd
> [26981]     0 26981    11386     2220      26        0             0
> systemd-udevd
> [26982]     0 26982    24905      290      16        0             0
> htop [26983]     0 26983    11386     2221      26
> 0             0 systemd-udevd
> [26984]     0 26984    11386     2221      26        0             0
> systemd-udevd
> [26985]     0 26985    11386     2221      26        0             0
> systemd-udevd
> [26986]     0 26986    11386     2221      26        0             0
> systemd-udevd
> [26987]     0 26987    11386     2221      26        0             0
> systemd-udevd
> [26988]     0 26988    11386     2221      26        0             0
> systemd-udevd
> [26989]     0 26989    11386     2221      26        0             0
> systemd-udevd
> [26990]     0 26990    11386     2222      26        0             0
> systemd-udevd
> [26991]     0 26991    11386     2222      26        0             0
> systemd-udevd
> [26992]     0 26992    11386     2222      26        0             0
> systemd-udevd
> [26993]     0 26993    11386     2222      26        0             0
> systemd-udevd
> [26994]     0 26994    11386     2222      26        0             0
> systemd-udevd
> [26995]     0 26995    11386     2222      26        0             0
> systemd-udevd
> [26996]     0 26996    11386     2223      26        0             0
> systemd-udevd
> [26997]     0 26997    11386     2223      26        0             0
> systemd-udevd
> [26998]     0 26998    11386     2223      26        0             0
> systemd-udevd
> [26999]     0 26999    11386     2223      26        0             0
> systemd-udevd
> [27000]     0 27000    11386     2223      26        0             0
> systemd-udevd
> [27001]     0 27001    11386     2223      26        0             0
> systemd-udevd
> [27002]     0 27002    11386     2223      26        0             0
> systemd-udevd
> [27003]     0 27003    11386     2224      26        0             0
> systemd-udevd
> [27004]     0 27004    11386     2224      26        0             0
> systemd-udevd
> [27005]     0 27005    11386     2224      26        0             0
> systemd-udevd
> [27006]     0 27006    11386     2224      26        0             0
> systemd-udevd
> [27007]     0 27007    11386     2224      26        0             0
> systemd-udevd
> [27008]     0 27008    11386     2224      26        0             0
> systemd-udevd
> [27010]     0 27010    11386     2224      26        0             0
> systemd-udevd
> [27011]     0 27011    11386     2225      26        0             0
> systemd-udevd
> [27012]     0 27012    11386     2225      26        0             0
> systemd-udevd
> [27013]     0 27013    11386     2225      26        0             0
> systemd-udevd
> [27014]     0 27014    11386     2225      26        0             0
> systemd-udevd
> [27015]     0 27015    11386     2225      26        0             0
> systemd-udevd
> [27016]     0 27016    11386     2225      26        0             0
> systemd-udevd
> [27017]     0 27017    11386     2225      26        0             0
> systemd-udevd
> [27018]     0 27018    11386     2226      26        0             0
> systemd-udevd
> [27019]     0 27019    11386     2226      26        0             0
> systemd-udevd
> [27020]     0 27020    11386     2226      26        0             0
> systemd-udevd
> [27021]     0 27021    11386     2226      26        0             0
> systemd-udevd
> [27022]     0 27022    11386     2226      26        0             0
> systemd-udevd
> [27023]     0 27023    11386     2226      26        0             0
> systemd-udevd
> [27024]     0 27024    11386     2227      26        0             0
> systemd-udevd
> [27025]     0 27025    11386     2227      26        0             0
> systemd-udevd
> [27026]     0 27026    11386     2227      26        0             0
> systemd-udevd
> [27027]     0 27027    11386     2227      26        0             0
> systemd-udevd
> [27028]     0 27028    11386     2227      26        0             0
> systemd-udevd
> [27029]     0 27029    11386     2227      26        0             0
> systemd-udevd
> [27030]     0 27030    11386     2227      26        0             0
> systemd-udevd
> [27031]     0 27031    11386     2228      26        0             0
> systemd-udevd
> [27032]     0 27032    11386     2228      26        0             0
> systemd-udevd
> [27033]     0 27033    11386     2228      26        0             0
> systemd-udevd
> [27034]     0 27034    11386     2228      26        0             0
> systemd-udevd
> [27035]     0 27035    11386     2228      26        0             0
> systemd-udevd
> [27036]     0 27036    11386     2228      26        0             0
> systemd-udevd
> [27037]     0 27037    11386     2228      26        0             0
> systemd-udevd
> [27038]     0 27038    11386     2229      26        0             0
> systemd-udevd
> [27039]     0 27039    11386     2229      26        0             0
> systemd-udevd
> [27040]     0 27040    11386     2229      26        0             0
> systemd-udevd
> [27041]     0 27041    11386     2229      26        0             0
> systemd-udevd
> [27042]     0 27042    11386     2229      26        0             0
> systemd-udevd
> [27043]     0 27043    11386     2229      26        0             0
> systemd-udevd
> [27044]     0 27044    11386     2229      26        0             0
> systemd-udevd
> [27045]     0 27045    11386     2230      26        0             0
> systemd-udevd
> [27046]     0 27046    11386     2230      26        0             0
> systemd-udevd
> [27047]     0 27047    11386     2230      26        0             0
> systemd-udevd
> [27048]     0 27048    11386     2230      26        0             0
> systemd-udevd
> [27049]     0 27049    11386     2230      26        0             0
> systemd-udevd
> [27050]     0 27050    11386     2230      26        0             0
> systemd-udevd
> [27051]     0 27051    11386     2231      26        0             0
> systemd-udevd
> [27052]     0 27052    11386     2231      26        0             0
> systemd-udevd
> [27053]     0 27053    11386     2231      26        0             0
> systemd-udevd
> [27054]     0 27054    11386     2231      26        0             0
> systemd-udevd
> [27055]     0 27055    11386     2231      26        0             0
> systemd-udevd
> [27056]     0 27056    11386     2231      26        0             0
> systemd-udevd
> [27057]     0 27057    11386     2231      26        0             0
> systemd-udevd
> [27058]     0 27058    11386     2232      26        0             0
> systemd-udevd
> [27059]     0 27059    11386     2232      26        0             0
> systemd-udevd
> [27060]     0 27060    11386     2232      26        0             0
> systemd-udevd
> [27061]     0 27061    11386     2232      26        0             0
> systemd-udevd
> [27062]     0 27062    11386     2232      26        0             0
> systemd-udevd
> [27063]     0 27063    11386     2232      26        0             0
> systemd-udevd
> [27064]     0 27064    11386     2232      26        0             0
> systemd-udevd
> [27065]     0 27065    11386     2233      26        0             0
> systemd-udevd
> [27066]     0 27066    11386     2233      26        0             0
> systemd-udevd
> [27067]     0 27067    11386     2233      26        0             0
> systemd-udevd
> [27068]     0 27068    11386     2233      26        0             0
> systemd-udevd
> [27069]     0 27069    11386     2233      26        0             0
> systemd-udevd
> [27070]     0 27070    11386     2233      26        0             0
> systemd-udevd
> [27071]     0 27071    11386     2234      26        0             0
> systemd-udevd
> [27072]     0 27072    11386     2234      26        0             0
> systemd-udevd
> [27073]     0 27073    11386     2234      26        0             0
> systemd-udevd
> [27074]     0 27074    11386     2234      26        0             0
> systemd-udevd
> [27075]     0 27075    11386     2234      26        0             0
> systemd-udevd
> [27076]     0 27076    11386     2234      26        0             0
> systemd-udevd
> [27077]     0 27077    11386     2234      26        0             0
> systemd-udevd
> [27078]     0 27078    11386     2235      26        0             0
> systemd-udevd
> [27079]     0 27079    11386     2235      26        0             0
> systemd-udevd
> [27080]     0 27080    11386     2235      26        0             0
> systemd-udevd
> [27081]     0 27081    11386     2235      26        0             0
> systemd-udevd
> [27082]     0 27082    11386     2235      26        0             0
> systemd-udevd
> [27083]     0 27083    11386     2235      26        0             0
> systemd-udevd
> [27084]     0 27084    11386     2235      26        0             0
> systemd-udevd
> [27085]     0 27085    11386     2236      26        0             0
> systemd-udevd
> [27086]     0 27086    11386     2236      26        0             0
> systemd-udevd
> [27087]     0 27087    11386     2236      26        0             0
> systemd-udevd
> [27088]     0 27088    11386     2236      26        0             0
> systemd-udevd
> [27089]     0 27089    11386     2236      26        0             0
> systemd-udevd
> [27090]     0 27090    11386     2236      26        0             0
> systemd-udevd
> [27091]     0 27091    11386     2236      26        0             0
> systemd-udevd
> [27092]     0 27092    11386     2237      26        0             0
> systemd-udevd
> [27093]     0 27093    11386     2237      26        0             0
> systemd-udevd
> [27094]     0 27094    11386     2237      26        0             0
> systemd-udevd
> [27095]     0 27095    11386     2237      26        0             0
> systemd-udevd
> [27096]     0 27096    11386     2237      26        0             0
> systemd-udevd
> [27097]     0 27097    11386     2237      26        0             0
> systemd-udevd
> [27098]     0 27098    11386     2238      26        0             0
> systemd-udevd
> [27099]     0 27099    11386     2238      26        0             0
> systemd-udevd
> [27100]     0 27100    11386     2238      26        0             0
> systemd-udevd
> [27101]     0 27101    11386     2238      26        0             0
> systemd-udevd
> [27102]     0 27102    11386     2238      26        0             0
> systemd-udevd
> [27103]     0 27103    11386     2238      26        0             0
> systemd-udevd
> [27104]     0 27104    11386     2238      26        0             0
> systemd-udevd
> [27105]     0 27105    11386     2239      26        0             0
> systemd-udevd
> [27106]     0 27106    11386     2239      26        0             0
> systemd-udevd
> [27107]     0 27107    11386     2239      26        0             0
> systemd-udevd
> [27108]     0 27108    11386     2239      26        0             0
> systemd-udevd
> [27109]     0 27109    11386     2239      26        0             0
> systemd-udevd
> [27110]     0 27110    11386     2239      26        0             0
> systemd-udevd
> [27111]     0 27111    11386     2239      26        0             0
> systemd-udevd
> [27112]     0 27112    11419     2240      26        0             0
> systemd-udevd
> [27113]     0 27113    11419     2240      26        0             0
> systemd-udevd
> [27114]     0 27114    11419     2240      26        0             0
> systemd-udevd
> [27115]     0 27115    11419     2240      26        0             0
> systemd-udevd
> [27116]     0 27116    11419     2240      26        0             0
> systemd-udevd
> [27117]     0 27117    11419     2240      26        0             0
> systemd-udevd
> [27118]     0 27118    11419     2240      26        0             0
> systemd-udevd
> [27119]     0 27119    11419     2241      26        0             0
> systemd-udevd
> [27120]     0 27120    11419     2241      26        0             0
> systemd-udevd
> [27121]     0 27121    11419     2241      26        0             0
> systemd-udevd
> [27122]     0 27122    11419     2241      26        0             0
> systemd-udevd
> [27123]     0 27123    11419     2241      26        0             0
> systemd-udevd
> [27124]     0 27124    11419     2241      26        0             0
> systemd-udevd
> [27125]     0 27125    11419     2242      26        0             0
> systemd-udevd
> [27126]     0 27126    11419     2242      26        0             0
> systemd-udevd
> [27127]     0 27127    11419     2242      26        0             0
> systemd-udevd
> [27128]     0 27128    11419     2242      26        0             0
> systemd-udevd
> [27129]     0 27129    11419     2242      26        0             0
> systemd-udevd
> [27130]     0 27130    11419     2242      26        0             0
> systemd-udevd
> [27131]     0 27131    11419     2242      26        0             0
> systemd-udevd
> [27132]     0 27132    11419     2243      26        0             0
> systemd-udevd
> [27133]     0 27133    11419     2243      26        0             0
> systemd-udevd
> [27134]     0 27134    11419     2243      26        0             0
> systemd-udevd
> [27135]     0 27135    11419     2243      26        0             0
> systemd-udevd
> [27136]     0 27136    11419     2243      26        0             0
> systemd-udevd
> [27137]     0 27137    11419     2243      26        0             0
> systemd-udevd
> [27138]     0 27138    11419     2243      26        0             0
> systemd-udevd
> [27139]     0 27139    11419     2244      26        0             0
> systemd-udevd
> [27140]     0 27140    11419     2244      26        0             0
> systemd-udevd
> [27141]     0 27141    11419     2244      26        0             0
> systemd-udevd
> [27142]     0 27142    11419     2244      26        0             0
> systemd-udevd
> [27143]     0 27143    11419     2244      26        0             0
> systemd-udevd
> [27144]     0 27144    11419     2244      26        0             0
> systemd-udevd
> [27145]     0 27145    11419     2244      26        0             0
> systemd-udevd
> [27146]     0 27146    11419     2245      26        0             0
> systemd-udevd
> [27147]     0 27147    11419     2245      26        0             0
> systemd-udevd
> [27148]     0 27148    11419     2245      26        0             0
> systemd-udevd
> [27149]     0 27149    11419     2245      26        0             0
> systemd-udevd
> [27150]     0 27150    11419     2245      26        0             0
> systemd-udevd
> [27151]     0 27151    11419     2245      26        0             0
> systemd-udevd
> [27152]     0 27152    11419     2246      26        0             0
> systemd-udevd
> [27153]     0 27153    11419     2246      26        0             0
> systemd-udevd
> [27154]     0 27154    11419     2246      26        0             0
> systemd-udevd
> [27155]     0 27155    11419     2246      26        0             0
> systemd-udevd
> [27156]     0 27156    11419     2246      26        0             0
> systemd-udevd
> [27157]     0 27157    11419     2246      26        0             0
> systemd-udevd
> [27158]     0 27158    11419     2246      26        0             0
> systemd-udevd
> [27159]     0 27159    11419     2247      26        0             0
> systemd-udevd
> [27160]     0 27160    11419     2247      26        0             0
> systemd-udevd
> [27161]     0 27161    11419     2247      26        0             0
> systemd-udevd
> [27162]     0 27162    11419     2247      26        0             0
> systemd-udevd
> [27163]     0 27163    11419     2247      26        0             0
> systemd-udevd
> [27164]     0 27164    11419     2247      26        0             0
> systemd-udevd
> [27165]     0 27165    11419     2247      26        0             0
> systemd-udevd
> [27166]     0 27166    11419     2248      26        0             0
> systemd-udevd
> [27167]     0 27167    11419     2248      26        0             0
> systemd-udevd
> [27168]     0 27168    11419     2248      26        0             0
> systemd-udevd
> [27169]     0 27169    11419     2248      26        0             0
> systemd-udevd
> [27170]     0 27170    11419     2248      26        0             0
> systemd-udevd
> [27171]     0 27171    11419     2248      26        0             0
> systemd-udevd
> [27172]     0 27172    11419     2248      26        0             0
> systemd-udevd
> [27173]     0 27173    11419     2249      26        0             0
> systemd-udevd
> [27174]     0 27174    11419     2249      26        0             0
> systemd-udevd
> [27175]     0 27175    11419     2249      26        0             0
> systemd-udevd
> [27176]     0 27176    11419     2249      26        0             0
> systemd-udevd
> [27177]     0 27177    11419     2249      26        0             0
> systemd-udevd
> [27178]     0 27178    11419     2249      26        0             0
> systemd-udevd
> [27179]     0 27179    11419     2250      26        0             0
> systemd-udevd
> [27180]     0 27180    11419     2250      26        0             0
> systemd-udevd
> [27181]     0 27181    11419     2250      26        0             0
> systemd-udevd
> [27182]     0 27182    11419     2250      26        0             0
> systemd-udevd
> [27183]     0 27183    11419     2250      26        0             0
> systemd-udevd
> [27184]     0 27184    11419     2250      26        0             0
> systemd-udevd
> [27185]     0 27185    11419     2250      26        0             0
> systemd-udevd
> [27186]     0 27186    11419     2251      26        0             0
> systemd-udevd
> [27187]     0 27187    11419     2251      26        0             0
> systemd-udevd
> [27188]     0 27188    11419     2251      26        0             0
> systemd-udevd
> [27189]     0 27189    11419     2251      26        0             0
> systemd-udevd
> [27190]     0 27190    11419     2251      26        0             0
> systemd-udevd
> [27191]     0 27191    11419     2251      26        0             0
> systemd-udevd
> [27192]     0 27192    11419     2251      26        0             0
> systemd-udevd
> [27193]     0 27193    11419     2252      26        0             0
> systemd-udevd
> [27194]     0 27194    11419     2252      26        0             0
> systemd-udevd
> [27195]     0 27195    11419     2252      26        0             0
> systemd-udevd
> [27196]     0 27196    11419     2252      26        0             0
> systemd-udevd
> [27197]     0 27197    11419     2252      26        0             0
> systemd-udevd
> [27198]     0 27198    11419     2252      26        0             0
> systemd-udevd
> [27199]     0 27199    11419     2253      26        0             0
> systemd-udevd
> [27200]     0 27200    11419     2253      26        0             0
> systemd-udevd
> [27201]     0 27201    11419     2253      26        0             0
> systemd-udevd
> [27202]     0 27202    11419     2253      26        0             0
> systemd-udevd
> [27203]     0 27203    11419     2253      26        0             0
> systemd-udevd
> [27204]     0 27204    11419     2253      26        0             0
> systemd-udevd
> [27205]     0 27205    11419     2253      26        0             0
> systemd-udevd
> [27206]     0 27206    11419     2254      26        0             0
> systemd-udevd
> [27207]     0 27207    11419     2254      26        0             0
> systemd-udevd
> [27208]     0 27208    11419     2254      26        0             0
> systemd-udevd
> [27209]     0 27209    11419     2254      26        0             0
> systemd-udevd
> [27210]     0 27210    11419     2254      26        0             0
> systemd-udevd
> [27211]     0 27211    11419     2254      26        0             0
> systemd-udevd
> [27212]     0 27212    11419     2254      26        0             0
> systemd-udevd
> [27213]     0 27213    11419     2255      26        0             0
> systemd-udevd
> [27214]     0 27214    11419     2255      26        0             0
> systemd-udevd
> [27215]     0 27215    11419     2255      26        0             0
> systemd-udevd
> [27216]     0 27216    11419     2255      26        0             0
> systemd-udevd
> [27217]     0 27217    11419     2255      26        0             0
> systemd-udevd
> [27218]     0 27218    11419     2255      26        0             0
> systemd-udevd
> [27219]     0 27219    11419     2255      26        0             0
> systemd-udevd
> [27220]     0 27220    11419     2256      26        0             0
> systemd-udevd
> [27221]     0 27221    11419     2256      26        0             0
> systemd-udevd
> [27222]     0 27222    11419     2256      26        0             0
> systemd-udevd
> [27223]     0 27223    11419     2256      26        0             0
> systemd-udevd
> [27224]     0 27224    11419     2256      26        0             0
> systemd-udevd
> [27225]     0 27225    11419     2256      26        0             0
> systemd-udevd
> [27226]     0 27226    11419     2257      26        0             0
> systemd-udevd
> [27227]     0 27227    11419     2257      26        0             0
> systemd-udevd
> [27228]     0 27228    11419     2257      26        0             0
> systemd-udevd
> [27229]     0 27229    11419     2257      26        0             0
> systemd-udevd
> [27230]     0 27230    11419     2257      26        0             0
> systemd-udevd
> [27231]     0 27231    11419     2257      26        0             0
> systemd-udevd
> [27232]     0 27232    11419     2257      26        0             0
> systemd-udevd
> [27233]     0 27233    11419     2258      26        0             0
> systemd-udevd
> [27234]     0 27234    11419     2258      26        0             0
> systemd-udevd
> [27235]     0 27235    11419     2258      26        0             0
> systemd-udevd
> [27236]     0 27236    11419     2258      26        0             0
> systemd-udevd
> [27237]     0 27237    11419     2258      26        0             0
> systemd-udevd
> [27238]     0 27238    11419     2258      26        0             0
> systemd-udevd
> [27239]     0 27239    11419     2258      26        0             0
> systemd-udevd
> [27240]     0 27240    11419     2259      26        0             0
> systemd-udevd
> [27241]     0 27241    11419     2259      26        0             0
> systemd-udevd
> [27242]     0 27242    11419     2259      26        0             0
> systemd-udevd
> [27243]     0 27243    11419     2259      26        0             0
> systemd-udevd
> [27244]     0 27244    11419     2259      26        0             0
> systemd-udevd
> [27245]     0 27245    11419     2259      26        0             0
> systemd-udevd
> [27246]     0 27246    11419     2259      26        0             0
> systemd-udevd
> [27247]     0 27247    11419     2260      26        0             0
> systemd-udevd
> [27248]     0 27248    11419     2260      26        0             0
> systemd-udevd
> [27249]     0 27249    11419     2260      26        0             0
> systemd-udevd
> [27250]     0 27250    11419     2260      26        0             0
> systemd-udevd
> [27251]     0 27251    11419     2260      26        0             0
> systemd-udevd
> [27252]     0 27252    11419     2260      26        0             0
> systemd-udevd
> [27254]     0 27254    11419     2261      26        0             0
> systemd-udevd
> [27255]     0 27255    11419     2261      26        0             0
> systemd-udevd
> [27256]     0 27256    11419     2261      26        0             0
> systemd-udevd
> [27257]     0 27257    11419     2261      26        0             0
> systemd-udevd
> [27258]     0 27258    11419     2261      26        0             0
> systemd-udevd
> [27259]     0 27259    11419     2261      26        0             0
> systemd-udevd
> [27260]     0 27260    11419     2261      26        0             0
> systemd-udevd
> [27261]     0 27261    11419     2262      26        0             0
> systemd-udevd
> [27262]     0 27262    11419     2262      26        0             0
> systemd-udevd
> [27263]     0 27263    11419     2262      26        0             0
> systemd-udevd
> [27264]     0 27264    11419     2262      26        0             0
> systemd-udevd
> [27265]     0 27265    11419     2262      26        0             0
> systemd-udevd
> [27266]     0 27266    11419     2262      26        0             0
> systemd-udevd
> [27267]     0 27267    11419     2262      26        0             0
> systemd-udevd
> [27268]     0 27268    11419     2263      26        0             0
> systemd-udevd
> [27269]     0 27269    11419     2263      26        0             0
> systemd-udevd
> [27270]     0 27270    11419     2263      26        0             0
> systemd-udevd
> [27271]     0 27271    11419     2263      26        0             0
> systemd-udevd
> [27272]     0 27272    11419     2263      26        0             0
> systemd-udevd
> [27273]     0 27273    11419     2263      26        0             0
> systemd-udevd
> [27274]     0 27274    11419     2263      26        0             0
> systemd-udevd
> [27275]     0 27275    11419     2264      26        0             0
> systemd-udevd
> [27276]     0 27276    11419     2264      26        0             0
> systemd-udevd
> [27277]     0 27277    11419     2264      26        0             0
> systemd-udevd
> [27278]     0 27278    11419     2264      26        0             0
> systemd-udevd
> [27279]     0 27279    11419     2264      26        0             0
> systemd-udevd
> [27280]     0 27280    11419     2264      26        0             0
> systemd-udevd
> [27281]     0 27281    11419     2265      26        0             0
> systemd-udevd
> [27282]     0 27282    11419     2265      26        0             0
> systemd-udevd
> [27283]     0 27283    11419     2265      26        0             0
> systemd-udevd
> [27284]     0 27284    11419     2265      26        0             0
> systemd-udevd
> [27285]     0 27285    11419     2265      26        0             0
> systemd-udevd
> [27286]     0 27286    11419     2265      26        0             0
> systemd-udevd
> [27287]     0 27287    11419     2265      26        0             0
> systemd-udevd
> [27288]     0 27288    11419     2266      26        0             0
> systemd-udevd
> [27289]     0 27289    11419     2266      26        0             0
> systemd-udevd
> [27290]     0 27290    11419     2266      26        0             0
> systemd-udevd
> [27291]     0 27291    11419     2266      26        0             0
> systemd-udevd
> [27292]     0 27292    11419     2266      26        0             0
> systemd-udevd
> [27293]     0 27293    11419     2266      26        0             0
> systemd-udevd
> [27294]     0 27294    11419     2266      26        0             0
> systemd-udevd
> [27295]     0 27295    11419     2267      26        0             0
> systemd-udevd
> [27296]     0 27296    11419     2267      26        0             0
> systemd-udevd
> [27297]     0 27297    11419     2267      26        0             0
> systemd-udevd
> [27298]     0 27298    11419     2267      26        0             0
> systemd-udevd
> [27299]     0 27299    11419     2267      26        0             0
> systemd-udevd
> [27300]     0 27300    11419     2267      26        0             0
> systemd-udevd
> [27301]     0 27301    11419     2267      26        0             0
> systemd-udevd
> [27302]     0 27302    11419     2268      26        0             0
> systemd-udevd
> [27303]     0 27303    11419     2268      26        0             0
> systemd-udevd
> [27304]     0 27304    11419     2268      26        0             0
> systemd-udevd
> [27305]     0 27305    11419     2268      26        0             0
> systemd-udevd
> [27306]     0 27306    11419     2268      26        0             0
> systemd-udevd
> [27307]     0 27307    11419     2268      26        0             0
> systemd-udevd
> [27308]     0 27308    11419     2269      26        0             0
> systemd-udevd
> [27309]     0 27309    11419     2269      26        0             0
> systemd-udevd
> [27310]     0 27310    11419     2269      26        0             0
> systemd-udevd
> [27311]     0 27311    11419     2269      26        0             0
> systemd-udevd
> [27312]     0 27312    11419     2269      26        0             0
> systemd-udevd
> [27313]     0 27313    11419     2269      26        0             0
> systemd-udevd
> [27314]     0 27314    11419     2269      26        0             0
> systemd-udevd
> [27315]     0 27315    11419     2270      26        0             0
> systemd-udevd
> [27316]     0 27316    11419     2270      26        0             0
> systemd-udevd
> [27317]     0 27317    11419     2270      26        0             0
> systemd-udevd
> [27318]     0 27318    11419     2270      26        0             0
> systemd-udevd
> [27319]     0 27319    11419     2270      26        0             0
> systemd-udevd
> [27320]     0 27320    11419     2270      26        0             0
> systemd-udevd
> [27321]     0 27321    11419     2270      26        0             0
> systemd-udevd
> [27322]     0 27322    11419     2271      26        0             0
> systemd-udevd
> [27323]     0 27323    11419     2271      26        0             0
> systemd-udevd
> [27324]     0 27324    11419     2271      26        0             0
> systemd-udevd
> [27325]     0 27325    11419     2271      26        0             0
> systemd-udevd
> [27326]     0 27326    11419     2271      26        0             0
> systemd-udevd
> [27327]     0 27327    11419     2271      26        0             0
> systemd-udevd
> [27328]     0 27328    11419     2272      26        0             0
> systemd-udevd
> [27329]     0 27329    11419     2272      26        0             0
> systemd-udevd
> [27330]     0 27330    11419     2272      26        0             0
> systemd-udevd
> [27331]     0 27331    11419     2272      26        0             0
> systemd-udevd
> [27332]     0 27332    11419     2272      26        0             0
> systemd-udevd
> [27333]     0 27333    11419     2272      26        0             0
> systemd-udevd
> [27334]     0 27334    11419     2272      26        0             0
> systemd-udevd
> [27335]     0 27335    11452     2273      26        0             0
> systemd-udevd
> [27336]     0 27336    11452     2273      26        0             0
> systemd-udevd
> [27337]     0 27337    11452     2273      26        0             0
> systemd-udevd
> [27338]     0 27338    11452     2273      26        0             0
> systemd-udevd
> [27339]     0 27339    11452     2273      26        0             0
> systemd-udevd
> [27340]     0 27340    11452     2273      26        0             0
> systemd-udevd
> [27341]     0 27341    11452     2273      26        0             0
> systemd-udevd
> [27342]     0 27342    11452     2274      26        0             0
> systemd-udevd
> [27343]     0 27343    11452     2274      26        0             0
> systemd-udevd
> [27344]     0 27344    11452     2274      26        0             0
> systemd-udevd
> [27345]     0 27345    11452     2274      26        0             0
> systemd-udevd
> [27346]     0 27346    11452     2274      26        0             0
> systemd-udevd
> [27347]     0 27347    11452     2274      26        0             0
> systemd-udevd
> [27348]     0 27348    11452     2274      26        0             0
> systemd-udevd
> [27349]     0 27349    11452     2275      26        0             0
> systemd-udevd
> [27350]     0 27350    11452     2275      26        0             0
> systemd-udevd
> [27351]     0 27351    11452     2275      26        0             0
> systemd-udevd
> [27352]     0 27352    11452     2275      26        0             0
> systemd-udevd
> [27353]     0 27353    11452     2273      26        0             0
> systemd-udevd
> [27354]     0 27354    11452     2275      26        0             0
> systemd-udevd
> [27355]     0 27355    11452     2276      26        0             0
> systemd-udevd
> [27356]     0 27356    11452     2274      26        0             0
> systemd-udevd
> [27357]     0 27357    11452     2274      26        0         -1000
> systemd-udevd
> [27358]     0 27358    11453     2282      26        0         -1000
> systemd-udevd
> [27359]     0 27359    11453     2282      26        0         -1000
> systemd-udevd
> [27360]     0 27360    11453     2275      26        0         -1000
> systemd-udevd
> [27361]     0 27361    11453     2282      26        0         -1000
> systemd-udevd
> [27362]     0 27362    11453     2283      26        0         -1000
> systemd-udevd
> [27363]     0 27363    11453     2283      26        0         -1000
> systemd-udevd
> [27364]     0 27364    11453     2283      26        0         -1000
> systemd-udevd
> [27365]     0 27365    11453     2276      26        0         -1000
> systemd-udevd
> [27366]     0 27366    11453     2283      26        0         -1000
> systemd-udevd
> Out of memory: Kill process 9613 (firefox) score 52 or sacrifice child
> Killed process 9613 (firefox) total-vm:1578420kB, anon-rss:314072kB,
> file-rss:228kB
> XMPP::NetTracke invoked oom-killer: gfp_mask=0x201da, order=0,
> oom_score_adj=0
> XMPP::NetTracke cpuset=/ mems_allowed=0
> Pid: 10557, comm: XMPP::NetTracke Not tainted
> 3.7.0-rc5-next-20121115_64+ #1697
> Call Trace:
>  [<ffffffff810e7e71>] ? cpuset_print_task_mems_allowed+0x91/0xa0
>  [<ffffffff816a7b5b>] dump_header.isra.10+0x6b/0x1a7
>  [<ffffffff812fd066>] ? ___ratelimit+0x96/0x110
>  [<ffffffff8112485f>] oom_kill_process+0x1cf/0x320
>  [<ffffffff8108b1d7>] ? has_ns_capability_noaudit+0x17/0x20
>  [<ffffffff81124dc0>] out_of_memory+0x250/0x280
>  [<ffffffff811295d7>] __alloc_pages_nodemask+0x857/0x920
>  [<ffffffff8112365d>] filemap_fault+0x28d/0x440
>  [<ffffffff811444fa>] __do_fault+0x6a/0x460
>  [<ffffffff81147149>] handle_pte_fault+0x89/0x900
>  [<ffffffff810b0176>] ? ttwu_do_activate.constprop.88+0x66/0x70
>  [<ffffffff811482bb>] handle_mm_fault+0x26b/0x370
>  [<ffffffff81071e15>] __do_page_fault+0x145/0x480
>  [<ffffffff810c4fdc>] ? ktime_get_ts+0x4c/0x100
>  [<ffffffff81180132>] ? poll_select_set_timeout+0x72/0x90
>  [<ffffffff8107218e>] do_page_fault+0xe/0x10
>  [<ffffffff816b03f2>] page_fault+0x22/0x30
> Mem-Info:
> DMA per-cpu:
> CPU    0: hi:    0, btch:   1 usd:   0
> CPU    1: hi:    0, btch:   1 usd:   0
> DMA32 per-cpu:
> CPU    0: hi:  186, btch:  31 usd:   0
> CPU    1: hi:  186, btch:  31 usd:   0
> Normal per-cpu:
> CPU    0: hi:  186, btch:  31 usd:   0
> CPU    1: hi:  186, btch:  31 usd:  23
> active_anon:1359088 inactive_anon:74743 isolated_anon:0
>  active_file:74 inactive_file:909 isolated_file:125
>  unevictable:0 dirty:0 writeback:0 unstable:0
>  free:23985 slab_reclaimable:4484 slab_unreclaimable:9967
>  mapped:13361 shmem:81578 pagetables:22923 bounce:0
>  free_cma:0
> DMA free:15956kB min:176kB low:220kB high:264kB active_anon:0kB
> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
> isolated(anon):0kB isolated(file):0kB present:15956kB mlocked:0kB
> dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB
> slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0
> all_unreclaimable? yes
> lowmem_reserve[]: 0 2711 5866 5866
> DMA32 free:43736kB min:31152kB low:38940kB high:46728kB
> active_anon:2665552kB inactive_anon:14280kB active_file:0kB
> inactive_file:1684kB unevictable:0kB isolated(anon):0kB
> isolated(file):0kB present:2776260kB mlocked:0kB dirty:0kB
> writeback:0kB mapped:1036kB shmem:14532kB slab_reclaimable:1136kB
> slab_unreclaimable:10812kB kernel_stack:2416kB pagetables:32168kB
> unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB
> pages_scanned:84031 all_unreclaimable? yes
> lowmem_reserve[]: 0 0 3154 3154
> Normal free:36248kB min:36252kB low:45312kB high:54376kB
> active_anon:2770800kB inactive_anon:284692kB active_file:296kB
> inactive_file:1952kB unevictable:0kB isolated(anon):0kB
> isolated(file):500kB present:3230696kB mlocked:0kB dirty:0kB
> writeback:0kB mapped:52408kB shmem:311780kB slab_reclaimable:16800kB
> slab_unreclaimable:29056kB kernel_stack:5040kB pagetables:59524kB
> unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB
> pages_scanned:24064 all_unreclaimable? yes
> lowmem_reserve[]: 0 0 0 0
> DMA: 1*4kB (U) 2*8kB (U) 2*16kB (U) 1*32kB (U) 2*64kB (U) 1*128kB (U)
> 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15956kB
> DMA32: 42*4kB (UEM) 49*8kB (UEM) 46*16kB (UEM) 20*32kB (UE) 26*64kB
> (UEM) 22*128kB (UE) 18*256kB (UEM) 40*512kB (UEM) 8*1024kB (U)
> 0*2048kB 1*4096kB (R) = 43792kB
> Normal: 514*4kB (UEM) 341*8kB (UEM) 443*16kB (UEM) 313*32kB (UEM)
> 100*64kB (EM) 44*128kB (EM) 1*256kB (M) 0*512kB 0*1024kB 1*2048kB (R)
> 0*4096kB = 36224kB
> 82803 total pagecache pages
> 0 pages in swap cache
> Swap cache stats: add 0, delete 0, find 0/0
> Free swap  = 0kB
> Total swap = 0kB
> 1556479 pages RAM
> 49776 pages reserved
> 635828 pages shared
> 1393234 pages non-shared
> 
> regards,

Already raised this issue on systemd mailing list. So systemd
upstream also knows about this.

-- 
Robert Milasan

L3 Support Engineer
SUSE Linux (http://www.suse.com)
email: rmilasan@suse.com
GPG fingerprint: B6FE F4A8 0FA3 3040 3402  6FE7 2F64 167C 1909 6D1A
