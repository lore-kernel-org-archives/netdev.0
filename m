From: cliff white <cliffw@osdl.org>
Subject: ethtool test script builder
Date: Thu, 24 Mar 2005 16:11:29 -0800
Message-ID: <20050324161129.3b85da16@es175>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary=Multipart_Thu__24_Mar_2005_16_11_29_-0800_K1Uf+qR_tUn3JeF2
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Multipart_Thu__24_Mar_2005_16_11_29_-0800_K1Uf+qR_tUn3JeF2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


This is useful to me, though not yet complete. Thought i would send it our and
see if anyone else could use it. 

It's a simple bash script that, given a .c file as input, greps for ethtool_ops, and 
writes a second bash file that tests the defined ops. 

I've finished the 'get_' side, working on the rest. Please comment.
cliffw
http://developer.osdl.org/cliffw/netdev/index.html

Useage: ethmaker.sh <infile> <outfile>



-- 
"Ive always gone through periods where I bolt upright at four in the morning; 
now at least theres a reason." -Michael Feldman

--Multipart_Thu__24_Mar_2005_16_11_29_-0800_K1Uf+qR_tUn3JeF2
Content-Type: text/plain; name=ethmaker.sh
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=ethmaker.sh

#!/bin/bash
# set -x
# Copyleft Cliff White && OSDL, 2005
INFILE=$1
OUTFILE=$2

if [ $# -ne 2 ]; then
	echo "Usage $0 <infile> <outfile>"
	exit 1
fi

if [ ! -f $INFILE ]; then
    echo "$INFILE not found, exiting"
    exit 1
fi

grep ethtool_ops $INFILE
if [ $? -eq 1 ]; then
    echo "No ethtool_ops defined in this tool"
    exit 1
fi

# eth - this script is created to allow some simple testing 
# of ethernet interfaces.
# Here's the idea:
# Look through the .c file for the interface, find all the ethtool_ops
# defined and add calls to the bash file for each op.



t_get_settings() {
    echo " " >> $OUTFILE
    echo "echo 'Testing get_settings - please examine output'" >> $OUTFILE
    echo "ethtool -i \$EDEV" >> $OUTFILE
}

t_check_get() {
    echo " " >> $OUTFILE

    echo "echo 'Checking $2 parameters'" >> $OUTFILE
    echo "ethtool $1 \$EDEV" >> $OUTFILE
    echo "if [ \$? -ne 0 ]; then" >> $OUTFILE
	echo "         echo 'Getting $2 parameters failed'" >> $OUTFILE
    echo "else" >> $OUTFILE
	echo "         echo 'Get $2 parameters passed'" >> $OUTFILE
    echo "fi" >> $OUTFILE
}
t_run_test() {
    echo " " >> $OUTFILE

    echo "echo 'Performing online test'" >> $OUTFILE
    echo "ethtool -t $EDEV online" >> $OUTFILE
    echo "if [ $? -ne 0 ]; then" >> $OUTFILE
	echo "         echo 'Online test failed'" >> $OUTFILE
    echo "else" >> $OUTFILE
	echo "         echo 'Online test passed'" >> $OUTFILE
    echo "fi" >> $OUTFILE
    echo "echo 'Performing offline test'" >> $OUTFILE
    echo "ethtool -t $EDEV offline" >> $OUTFILE
    echo "if [ $? -ne 0 ]; then" >> $OUTFILE
	echo "e         cho 'Offline test failed'" >> $OUTFILE
    echo "else" >> $OUTFILE
	echo "         echo 'Offline test passed'" >> $OUTFILE
    echo "fi" >> $OUTFILE
} 

t_set_speed_10() {
    echo " " >> $OUTFILE

    echo "echo 'Setting speed to 10Mb'" >> $OUTFILE
    echo "if [ \`ethtool -s \$EDEV speed 10 2>&1 | wc -l\` -eq 0 ]; then" >> $OUTFILE
    echo "         echo 'Setting speed 10 okay'" >> $OUTFILE
    echo "else" >> $OUTFILE
    echo  "         echo 'Setting speed 10 failed'" >> $OUTFILE
    echo "fi" >> $OUTFILE
}

t_set_speed_100() {
    echo " " >> $OUTFILE

    echo "echo 'Setting speed to 100Mb'" >> $OUTFILE
    echo "if [ \`ethtool -s \$EDEV speed 100 2>&1 | wc -l\` -eq 0 ]; then" >> $OUTFILE
    echo "         echo 'Setting speed 100 okay'" >> $OUTFILE
    echo "else" >> $OUTFILE
    echo  "         echo 'Setting speed 100 failed'" >> $OUTFILE
    echo "fi" >> $OUTFILE
}

t_set_speed_1000() {
    echo " " >> $OUTFILE

    echo "echo 'Setting speed to 1000Mb'" >> $OUTFILE
    echo "if [ \`ethtool -s \$EDEV speed 1000 2>&1 | wc -l\` -eq 0 ]; then" >> $OUTFILE
    echo "         echo 'Setting speed 1000 okay'" >> $OUTFILE
    echo "else" >> $OUTFILE
    echo  "         echo 'Setting speed 1000 failed'" >> $OUTFILE
    echo "fi" >> $OUTFILE
}

t_id_dev() {
      echo " " >> $OUTFILE
    echo "echo 'Testing get_settings - please examine output'" >> $OUTFILE
    echo "ethtool -i \$EDEV" >> $OUTFILE
}

t_check_get() {
    echo " " >> $OUTFILE

    echo "echo 'Checking $2 parameters'" >> $OUTFILE
    echo "ethtool $1 \$EDEV" >> $OUTFILE
    echo "if [ \$? -ne 0 ]; then" >> $OUTFILE
	echo "         echo 'Getting $2 parameters failed'" >> $OUTFILE
    echo "else" >> $OUTFILE
	echo "         echo 'Get $2 parameters passed'" >> $OUTFILE
    echo "fi" >> $OUTFILE
}
t_run_test() {
    echo " " >> $OUTFILE

    echo "echo 'Performing online test'" >> $OUTFILE
    echo "ethtool -t $EDEV online" >> $OUTFILE
    echo "if [ $? -ne 0 ]; then" >> $OUTFILE
	echo "         echo 'Online test failed'" >> $OUTFILE
    echo "else" >> $OUTFILE
	echo "         echo 'Online test passed'" >> $OUTFILE
    echo "fi" >> $OUTFILE
    echo "echo 'Performing offline test'" >> $OUTFILE
    echo "ethtool -t $EDEV offline" >> $OUTFILE
    echo "if [ $? -ne 0 ]; then" >> $OUTFILE
	echo "e         cho 'Offline test failed'" >> $OUTFILE
    echo "else" >> $OUTFILE
	echo "         echo 'Offline test passed'" >> $OUTFILE
    echo "fi" >> $OUTFILE
} 

t_set_speed_10() {
    echo " " >> $OUTFILE

    echo "echo 'Setting speed to 10Mb'" >> $OUTFILE
    echo "if [ \`ethtool -s \$EDEV speed 10 2>&1 | wc -l\` -eq 0 ]; then" >> $OUTFILE
    echo "         echo 'Setting speed 10 okay'" >> $OUTFILE
    echo "else" >> $OUTFILE
    echo  "         echo 'Setting speed 10 failed'" >> $OUTFILE
    echo "fi" >> $OUTFILE
}

t_set_speed_100() {
    echo " " >> $OUTFILE

    echo "echo 'Identifying device for next 10 seconds'" >> $OUTFILE
    echo "ethtool -p \$EDEV 10" >> $OUTFILE
}


write_bp() {
  echo  "#!/bin/bash" > $OUTFILE
  echo "# Script to test the ethtool ops for $INFILE" >> $OUTFILE
  echo  "# Test for proper input" >> $OUTFILE
  echo "if [ \$# -ne 1 ]; then"  >> $OUTFILE
  echo "         echo 'Usage: \$0 <interface>'"  >> $OUTFILE
  echo "         exit 1" >> $OUTFILE
  echo  "else" >> $OUTFILE
  echo  "        export EDEV=\$1" >> $OUTFILE
  echo  "fi"  >> $OUTFILE

}
write_bp
# get tests
# get settings test
RES=`grep -c '.get_settings' $INFILE`
if [ $RES -gt 0 ]; then
    t_get_settings
fi

# -a MODE_GPAUSE
# ethtool -a - get pause settings
RES=`grep -c '.get_pauseparam' $INFILE`
if [ $RES -gt 0 ];then
    t_check_get '-a' 'pause'
fi

# -c MODE_GCOALESCE
# ethtool -c - coalesce
RES=`grep -c '.get_coalesce' $INFILE`
if [ $RES -gt 0 ]; then
    t_check_get '-c' 'coalesce'
fi

# -g MODE_GRING
#ethtool -g - ring parameters
RES=`grep -c '.get_ringparam' $INFILE`
if [ $RES -gt 0 ]; then
    t_check_get '-g' 'ring' 
fi

# -i MODE_GDRV
#ethtool -i - drive info
RES=`grep -c '.get_drvinfo' $INFILE`
if [ $RES -gt 0 ]; then
    t_check_get '-i' 'device info'
fi

# -k MODE_GOFFLOAD
# ethtool -k TCP segmentation
RES=`grep -c '.get_tso' $INFILE`
if [ $RES -gt 0 ]; then
    t_check_get '-k' 'TCP offload'
fi

# -d MODE_GREGS
RES=`grep -c '.get_regs' $INFILE`
if [ $RES -gt 0 ]; then
    t_check_get '-d' 'register'
fi

# -e MODE_GEEPROM
RES=`grep -c '.get_eeprom' $INFILE`
if [ $RES -gt 0 ]; then
    t_check_get '-e' 'EEPROM'
fi

# There apparently is no way to query the settings under '-s' expect in the general query
# other

# -r MODE_NWAY_RST 
# restart autonegotion - look for error
RES=`grep -c '.nway_reset' $INFILE`
if [ $RES -gt 0 ];then
    t_check_get '-r' 'Restart autonegotiate'
fi

# -p MODE_PHYS_ID
# blinkenlights
RES=`grep -c '.phys_id' $INFILE`
if [ $RES -gt 0 ]; then
    t_id_dev
fi

# -t MODE_TEST
RES=`grep -c '.self_test' $INFILE`
if [ $RES -gt 0 ]; then
    t_run_test
fi

# -S MODE_GSTATS
RES=`grep -c '.get_stats' $INFILE`
if [ $RES -gt 0 ]; then 
    t_check_get '-S' 'Statistics'
fi

# set tests 
# -A MODE_SPAUSE
# -C MODE_SCOALESCE
# -G MODE_SRING
# -K MODE_SOFFLOAD
# -E MODE_SEEPROM
# 

# set settings 
RES=`grep -c '.set_settings' $INFILE`
if [ $RES -gt 0 ]; then
    echo "echo 'Testing .set_settings'" >> $OUTFILE
    RES2=`egrep -c 'SUPPORTED_10b|SPEED_10' $INFILE`
    if [ $RES2 -gt 0 ]; then
	t_set_speed_10
    fi
   
    RES2=`egrep -c 'SUPPORTED_100b|SPEED_100' $INFILE `
    if [ $RES2 -gt 0 ]; then
	t_set_speed_100
    fi    
   
    RES2=`egrep -c 'SUPPORTED_1000b|SPEED_1000' $INFILE`
    if [ $RES2 -gt 0 ]; then
	t_set_speed_1000
    fi	  
fi




#
#
# * &ethtool_ops - Alter and report network device settings
# * get_settings: Get device-specific settings - [DONE]
# * set_settings: Set device-specific settings
# * get_drvinfo: Report driver information - [DONE]
# * get_regs: Get device registers - [DONE]
# * get_wol: Report whether Wake-on-Lan is enabled  - [in get_settings]
# * set_wol: Turn Wake-on-Lan on or off
# * get_msglevel: Report driver message level  - [in get_settings]
# * set_msglevel: Set driver message level
# * nway_reset: Restart autonegotiation - [DONE]
# * get_link: Get link status - [ in get_settings ]
# * get_eeprom: Read data from the device EEPROM - [DONE]
# * set_eeprom: Write data to the device EEPROM
# * get_coalesce: Get interrupt coalescing parameters - [DONE]
# * set_coalesce: Set interrupt coalescing parameters
# * get_ringparam: Report ring sizes - [DONE]
# * set_ringparam: Set ring sizes
# * get_pauseparam: Report pause parameters - [DONE]
# * set_pauseparam: Set pause paramters
# * get_rx_csum: Report whether receive checksums are turned on or off - [in get_tso]
# * set_rx_csum: Turn receive checksum on or off
# * get_tx_csum: Report whether transmit checksums are turned on or off - [in get_tso]
# * set_tx_csum: Turn transmit checksums on or off
# * get_sg: Report whether scatter-gather is enabled - [ in get_tso ]
# * set_sg: Turn scatter-gather on or off
# * get_tso: Report whether TCP segmentation offload is enabled - [ in get_tso ]
# * set_tso: Turn TCP segmentation offload on or off
# * self_test: Run specified self-tests - [DONE]
# * get_strings: Return a set of strings that describe the requested objects
# * phys_id: Identify the device - [DONE]
# * get_stats: Return statistics about the device

--Multipart_Thu__24_Mar_2005_16_11_29_-0800_K1Uf+qR_tUn3JeF2--
