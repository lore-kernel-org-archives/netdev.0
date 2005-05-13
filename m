From: Arthur Kepner <akepner@sgi.com>
Subject: Perf data with recent tg3 patches
Date: Thu, 12 May 2005 19:49:57 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0505121942190.14917@linux.site>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1586889132-1115952411=:14917"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, mchan@broadcom.com
Content-ID: <Pine.LNX.4.61.0505121947110.14917@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1586889132-1115952411=:14917
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.61.0505121947111.14917@linux.site>



Several tg3 patches have been recently posted, and I've 
collected a bit of performance data with them. Mostly 
I'm concerned about reducing per-interrupt overhead 
(due to PIOs), and CPU Utilization, so the following data 
shows how these patches change the number of received 
packets/interrupt and CPU utilization.

(Let me know if I've missed any relevant patches.) 

The data is labelled as follows:
-------------------------------
base                : "vanilla" 2.6.12-rc2 kernel
base+mchan1-3       : 2.6.12-rc2 kernel + 3 patches 
                      from mchan [1]
base+mchan1-3+tagged: 2.6.12-rc2 + 3 patches
                      from mchan [1] + tagged status 
                      patch from davem [2]
base+mchan1-3+coal  : 2.6.12-rc2 + 3 patches
                      from mchan [1] + tg3 interrupt 
                      coalescence patch [3] 

[1] http://marc.theaimsgroup.com/?l=linux-netdev&m=111446723510962&w=2
(This is one of a series of 3 patches - the others can't be 
found in the archive. But they're all in 2.6.12-rc4.)
[2] http://marc.theaimsgroup.com/?l=linux-netdev&m=111567944730302&w=2
[3] http://marc.theaimsgroup.com/?l=linux-netdev&m=111586526522981&w=2

The system I used was an Altix with 1300MHz CPUs, and 
a 5704 Broadcom NIC. The workload was bulk data receive 
via TCP, with 1500 a byte MTU.

The following tables summarize the data in the attached 
graphs. I had to (grossly) interpolate in some cases, 
see the graphs for the real data. 

                            CPU Util[%]
               -------------------------------------
               base      base+      base+      base+
                       mchan1-3  mchan1-3+  mchan1-3+
Link Util[%]                      tagged       coal
=====================================================
    40         36        34        41          27
    60         48        45        50          35
    80         58        56        58          40
    90         59        58        63          42
    95         -         57        -           42


                            Packets/Intr
               -------------------------------------
               base      base+      base+      base+
                       mchan1-3  mchan1-3+  mchan1-3+
Link Util[%]                      tagged       coal
=====================================================
    40         2.2       2.3        1.4       3.4
    60         2.7       2.9        1.8       4.1
    80         3.0       3.2        2.3       5.2
    90         3.1       3.4        2.4       6.2
    95          -        3.5         -        6.6


"mchan1-3" gets us up to ~.5 more packets/interrupt, 
and adding the "coal" patch ~3.5 more. The "tagged" 
patch made things a bit worse, though I haven't pinned 
down exactly why that is. Processing more packets per 
interrupt results in lower CPU utilization, largely 
because we spend less time waiting for PIOs to flush.


--
Arthur
--8323584-1586889132-1115952411=:14917
Content-Type: IMAGE/PNG; NAME="cpu_vs_link.2.png"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.61.0505121946500.14917@linux.site>
Content-Description: CPU utilization
Content-Disposition: ATTACHMENT; FILENAME="cpu_vs_link.2.png"

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
L/8DP+kMARRS++4AAAAASUVORK5CYII=

--8323584-1586889132-1115952411=:14917
Content-Type: IMAGE/PNG; NAME="packets_vs_link.2.png"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.61.0505121946510.14917@linux.site>
Content-Description: Received Packets/Interrupt
Content-Disposition: ATTACHMENT; FILENAME="packets_vs_link.2.png"

iVBORw0KGgoAAAANSUhEUgAAAoAAAAHgAQAAAAAdquFJAAAAQ3RFWHRTb2Z0
d2FyZQBnbnVwbG90IHZlcnNpb24gNC4wIHBhdGNobGV2ZWwgMCBvbiBMaW51
eCAyLjYuOC0yNC1kZWZhdWx0nVoNlQAADZ5JREFUCJntnU+IZEcdx984SToi
2F70pOmAngTBo2jYzh7EgyAexOSQZcCTIjFikEZmu2vMHPbmQiBHSa5GyXpy
A5Pp14uCByGbS1hl2akGibvsuFM9WXeqZ+pVlVW/6j/1/var96pjj9s/SM/+
uqo/+davqt6relXvvUB6tmANXAPXwDVwDVwD10C/QLGpP9R/VHu7UrJ5Gp18
MMaljFBJILeBJAF8OAPelGWBwgJi38AwCZTzIpcHRq2hkOP2jmhIRP7TGnSv
qB/3GobFGwActssDuSS4RymmnAlJHhLGt9WPu8wUOWI0dCzypqRhnxBCmVRs
Slmkyoe2TWkZ5xQBkJQGqt+FYksBuQqfBkK8ujPgx9IVGDVCEQ6bVDTpHNhr
ToGPnIEqSkK1FyopmQH7UMMAPHEGUoihpIhhAO6rb+9IzbViiJ0U6lqWZ0yJ
UkCuw3fI6FgBqQaGklMROsVwKNi4zSMVtl1KoS/SqKn+jBpDBcRSNCXajVrl
gDVsDVwD18A1cA08b8AR8gwkoWcgxo8d0HsMVS0Pg5rWTCgk8A8x8as6Vgwf
N6D3GKpa9guswzjvwJLmHZhlqwJEywE6xJD6VviJAy+K5qi96xF4Qc14cdch
hgEqBiI14xXCo0IFJH6Bvc1RL3NIVBXYZbLvtR1uM3mQmVKxp1zgDIfII/Ci
2Bwil3ZYzh6r4+GSgOsYOgGt7zl8hlLu1olhCtiWsuugEKFsIJkCRVs6HQ/7
OQpnQF1kF+CdZL577RuiMULkER7yK+P2RQA6xPAwCbyLBWckJB9fw91tiS9o
IHdQmDrAEiIV5yCgnfA9LglC4aD1ZwdgSqECdtWgnihgZIBuClMxJGTQaw5a
Gsj5uAlAlxima5mEiKpZBwCpUehSy+l2SJC5mt0J9zkBYIl2OGjl9pS7ONym
KpF2cHeqMKOnDJtxhTgXeK89uNxU8xjaGUIM9YpARl8uDyxphMSBYU1gFARx
IKoJ5AmgqHtOGSeAqukPn3IRdCdh/3g6fomA1TwFiCChkNYFjp99IgYkNWMo
xkEciBNANP8nfK8XVluQzebFFH7FCXiqwkyKgPcSMZwDO8gCoinwGBajihQm
G/YM+Cdb4QwIa1IWMCOGecAP4XMyX0LvyMa/2zfOmgYoNsftG73PjNBrKYXi
JA/4T/g08yWJ3uixQyxOqQYSrRD3uw9JeDkFDEZ5QDOTMvOlUWNvn99VJynG
RSBaO211TFKzAHzgcsQ2CifzJbS3Lw1wqnACdDinmBhO5ksaqE5SBqgrRR1g
t9ngGReFk1qG+dIEGM6BFBQ6jW0m7dDMlxRQn5cAqNvhHeIONDadL+312VSh
7imHlOhalpedx4fT+dJe2IAYqpOU7st03MxuhwuBBYZYTkJFoI5u2sabFhA5
Aftcj8+SMWRsDsShE/CGaGZ8GwNiJ2C21VCYA9ybAaPpdZVa55SYQulDYQkg
trLDJ5KyMfniqg+gQFKwnLzxdhjPNLtUhed/gBMhyfk0dg59eTYkTgJ1kXkM
lLBFwA/QbtQcSnwY3mDNUW93AlQNW02rqgBvhpxRjPBHW/0zKvtdDWQCul7o
AuxMgRgL9dP3No4I+pU62qoTzE77ylCfAiQujOEoR6ECMhmGWAFPDRAUIsZg
51a+QoLygDuRPnMqIGOjZ8QkhtppFQITBwcL2NPLLAZIDiwgKVaYAM7boWJQ
AzTndtMOtVMcw7zD182wp4YjUh6R/lSh7imqlt0UzuwDtDNuDTXwBsRQn6Qa
cIAdtQov93k5wNrA6SpmvXmKBRxseFYY888B0Nci17jubNQCDlpS7w70WGQk
3admhcBQWhMfHzHENtCHwqUAB0jN6I9q2aAZUxh6jGEorSV1D0VWpfULBPMO
XN6ivy+F0mM7pLbvA0hs30cMsW+F5w3oIYbxSvGg0HuzgZOUT2DM/59tPimv
cBWB8VpexXaIzxlwFY+H5+3gsO7L9YEeYnjsW+ED38A7eKlADzFcssJVBD4I
baCHGE73x5+XrucLOFv093U8xD4VIs9AWAvwCsQ20Md5WStUc1xfCierFaG/
SwQY8Nj32AZ7jKFvhYbnGzi7ROALuLz7Anwp9AkctTwD4yPYVRxjnzfgKsbQ
+zxlfc1h5YErGEM+bdkrC4yClg2sH8PVL3Lc9w9cwXZ47oAeYoh8Kwx9A7Ej
cNhcAHQd28A26aIYul6dI3kZp8DcbUNVgdz2S9jRIqCIAT3E0HEz3uIiG0Oe
gaI8cGE7BOO+5ymsvMJcm/UUpP5Sj8CDUAJ1EXA6jlwIhItpePGi//vvl5zR
A7Dg7o+pwcWO0gpLtEPvwOl1Rkdgfms7wHkpiXZ4WFJh6SLT0DMw5hdY6XYY
Bz4eYxvkGRjfnOxjvoyXqrA+sNr26QLgObjm4B0Y8/0DV6Uv6/GJT+Drr2Of
QHY4CNpzYHwps0oMo0eDp9EcWHspE/3iR299Ts6BtZfh+u9++8UN5BF46aXf
/HEzzAM6x5Cxt+9/6flN7E0hpx+efPXXG8QbUJDDe59/LZBWLYe1gHLrw7//
bfADNAfGlzJdY0hp+Pa7d+cptXsKI1uXXn3VI5AfkL4NqA0U+3R6J4Gn4+E2
83s8FGEcoIG4DpDjFLDSNn4wfdsem/9sNoJFNtAphl3dDpVjZE6BZ/b/wM32
9Aflgm+FFjD7EoEI5GK7pT9OTsWll2xg9kWM7NsaE6Z/sq+BX7SAOddgZ886
TqVYzi1igM8HtkKw1F7iUgp1DPeD54Mg2EwCU0uZ4qgEUD9BYH8YfN08cy4G
VMNYd4U6zzj4wql4MV1kiavEUJKMSkkAXRRCCwHgczbQ9JRUDPPaIbcfX6GB
gslLz820T/vyuPx9Affj//6D/vtObNEf2woXh61jOYepbDNgMob5dm1WeCl3
2lZCVSC2gLG7ZmPAVDsspzAf6HBfwCyGPCeGUMvl7wuY3Zmpp/iZCh03Qc3b
YfJ5KrXPeuWADucU7nue4qvIuU8Ym1VKyzPwAbaBi2NIC7NVGBJnKYQTRlVg
5pPuXq4ENAPBLIX0y7nAohjCUDUzhuw7mcDR9I7sHDPPI8pSGNnTiumQ0Yyk
iuwwFygaFnB+7WsRMC9Z/OvnqZHDDFgUw8O8lJ/87GvZwE6xwtQznSZ29LuX
vpersMj6Od//5y/feqUSMPVMJzAWPB00OhawFQO6X3PgO0881Z6lBGp6OgMu
aofZj8w823n201sWkDssFGYB6S+D72+84g+4t/fjIHiqkw8sDBtKpLC3j253
t4LghXk2J4WpGPPrL98X3wie/W5FYKLI/I649vvj0ZPBk7/1AxS3ZeuvOxe+
GTyBbaDLXhEUT3lh/KngmF9644fIBs4sX2EYZiqUV5XC++ynezagFBCjzK+j
DRXD253ZEaU8MG8OdFXV8l4YB5Qa23yUk/KCaofJlFIKUw/LA9lE1XLMygM/
yvryBPPEAbdmDM/C5DflY3gTZaTAa5CqjQ9FkBIjsxbCyxc5MyX9oqYYsHAW
kJmyIIbu9y+f4MyU3Bn9QoXpDRnxGBYBS9qSgc4xzHGsWvZ3p/+E7rfIeGlA
XzFcnsKFZh3zi4AldmJM7DYqBZSlI3W/OJv79PY4N6UiMHbtxwfQVaGOR5jT
saGCq8QwZ+hhKvh2TmIRMG/oAeJKtkMLiOWjnF/kh68AKBSQ5bRDqOCSfXl5
CjWwMIbOwGijuJZdgTqGhe2wSgwr2nkF+jqnWAormwMwd6dqVSAM3SoCM4MD
g0ufMUwPf8srzLTcnapVgXUUfjIxrFPLmea9HZaz/6u+vFLApcawXGtZoNC2
cu15AdCWf9bPS3Eosp0Y9TwDh5+tDsxcAauj8NR3DI+zEk8OPBf56MgzsE5P
WQbQ7xsAM1+VUcXWQH9A72/z9GZr4BpYD2heY84lPMS4MW5L3dzBoeAMzOON
r9iOnY1E+rHIFtBsTTyF7WaCUazzhPD2mrvgYPMqm21wJE5lu8mImrlbQLN2
ewwbvjiHm+gmr3+4ZZzJ3jJze91BKttVStXM3QbCflsuIvhDbsLPwLkODoYU
Lk1KPzJASIFshN4N2zHgLQM8M8BrAASnAw6GFAWElN6ZAUIKZCP0Vj+u8LoB
npiAvgI6tCMoOIPeiQFqR0A2YbKRgxMAXt+PAzsGCCfjBowNxz3tcGoGin3t
RCYllm30DGwVoZ29GPCEGuABhP6BYWgn2jDOgXY4A4eZbMxKISf0egz4aALs
Q8EOTU4Y3VDL4RwcKizHpJBH9FoM+HAC7AHwrskJ4y9qOZyDQ4TlyL52yEP6
Zphuh9y0Q2m3Q2o506ZnN1fZExDDRDs0PYVDf+DS7inUciadA9sd6ggckuwp
pi+bfhltpPvyxDHdF9td/hic3WRf9mNr4Bq4Bq6Ba+AnD+STDwEv6WjNv1M2
boeZ7wdaAIxmwIcSmzGUhJGSZHILZV92qgwMqwClVWQ8/w6AIudq3gLgRQCO
mwAMes1hW51t39JAXgUYyQuczIssJOV64PsmUkBWBahIXQxApsYe6gvGJwMO
JmlF4OVwDmQ2kFRViOZAKjbnQFwVaCkk3FIY1ophB4CYMY6nwF4FoH6DTZfo
G2+uATDkTIRq0AbArnvD1kM61FWj0F2Jh3rgFvQ2JVKDNgUct4V7X65ma2B9
+y8aqfbN+WH4fAAAAABJRU5ErkJggg==

--8323584-1586889132-1115952411=:14917--
